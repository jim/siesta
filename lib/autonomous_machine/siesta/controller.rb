module AutonomousMachine
  module Siesta
    module Controller
      
      class ConfigurationError < StandardError; end
      class MissingResourceId < StandardError; end
        
      def self.included(base)
        base.extend(ClassMethods)
      end
    
      module ClassMethods
        
        attr_accessor :siesta_config
        
        def restful_actions_for(*args)
          options = args.extract_options! || {}
        
          self.siesta_config = {}
        
          resources = args.map{|r| r.to_s.singularize}
        
          self.siesta_config[:resource] = resources.pop
          raise ConfigurationError.new("Siesta requires at least one resource") unless self.siesta_config[:resource]
          raise ConfigurationError.new("Siesta cannot manage 'resource' resources") if self.siesta_config[:resource] == 'resource'
          
          self.siesta_config[:resource_chain] = resources
        
          instance_eval do
            
            include InstanceMethods
            # helper_method :edit_resource_path
            # helper_method :new_resource_path
            # helper_method :resource_path
            # helper_method :resources_path
          
            before_filter :load_resource_chain
            
          end
        
          if options[:public].respond_to? :each
            public *options[:public]
          elsif options[:public].is_a? Symbol
            if options[:public] == :all
              public :index, :new, :create, :update, :edit, :destroy, :show
            else
              public options[:public]
            end
          end
        end
        
        alias :siesta :restful_actions_for
        
      end
    
      module InstanceMethods
      
        private
      
        def create
          create_resource
          report message_for_create_success(@resource) if resource_created?
          respond_to_create
        end
      
        def destroy
          load_resource
          destroy_resource
          report message_for_destroy_success(@resource) if resource_destroyed?
          respond_to_destroy
        end
      
        def edit
          load_resource
          respond_to_edit
        end
      
        def index
          load_resources
          respond_to_index
        end
      
        def new
          new_resource
          respond_to_new
        end
      
        def show
          load_resource
          respond_to_show
        end
      
        def update
          load_resource
          update_resource
          report message_for_update_success(@resource) if resource_updated?
          respond_to_update
        end
      
        protected
      
        def new_resource
          source = resource_source(siesta_config(:resource))
          if source.respond_to?(:proxy_target)
            resource = source.build(resource_params(siesta_config(:resource)))
          else
            resource = source.new(resource_params(siesta_config(:resource)))
          end
        end
      
        def create_resource
          send_or_default("create_#{siesta_config(:resource)}") do
            new_resource
            resource = instance_variable_get("@#{resource_name}")
            resource.attributes=resource_params(siesta_config(:resource))
            resource.save
          end
        end
        
        def update_resource
          send_or_default("update_#{siesta_config(:resource)}") do
            resource = instance_variable_get("@#{resource_name}")
            resource.attributes=resource_params(siesta_config(:resource))
            resource.save
          end
        end

        def load_resource
          load_object(siesta_config(:resource))
        end

        def load_resources
          load_collection(siesta_config(:resource).pluralize)
        end
      
        def load_object(name)
          object = send_or_default("load_#{name}") do
            resource_source(name).find(resource_id(name))
          end
          instance_variable_set("@#{name}", object)
        end      
      
        def load_collection(name)
          collection = send_or_default("load_#{siesta_config(:resource).pluralize}") do
            resource_source(name).paginate(:all, {:page => params[:page]})
          end
          instance_variable_set("@#{resource_name.pluralize}", collection)
        end
      
        def send_or_default(method, &block)
          respond_to?(method) ? send(method) : block.call
        end
      
        def resource_source(name)
          send_or_default("#{name}_source") do
            if name == siesta_config(:resource) && !siesta_config(:resource_chain).empty?
              instance_variable_get("@#{siesta_config(:resource_chain).last}").send(siesta_config(:resource).pluralize)
            elsif siesta_config(:resource_chain).include?(name) && siesta_config(:resource_chain).first != name
              var_name = "@#{siesta_config(:resource_chain)[siesta_config(:resource_chain).index(name)-1]}"
              instance_variable_get(var_name).send(name.pluralize)
            else
              name.classify.constantize
            end
          end
        end
      
        def resource_params(attributes={})
          (params[siesta_config(:resource)] || {}).reject{|k, v| !allowed_params.include?(k.to_sym) }.merge(attributes)
        end
      
        def load_resource_chain
          siesta_config(:resource_chain).each do |name|
            load_object(name)
          end
        end
      
        def resource_id(name)
          id = name == siesta_config(:resource) ? params[:id] : params[name + '_id']
          raise MissingResourceId.new("No ID found for #{name}") unless id
          id
        end
      
        def message_for_create_success(resource); "The #{siesta_config(:resource)} has been created."; end
        def message_for_update_success(resource); "Your changes have been saved."; end
        def message_for_destroy_success(resource); "The #{siesta_config(:resource)} has been deleted."; end
      
        def respond_to_index; respond_to_action('index'); end
        def respond_to_show; respond_to_action('show'); end
        def respond_to_new; respond_to_action('new'); end
        def respond_to_create; respond_to_action('create'); end
        def respond_to_edit; respond_to_action('edit'); end
        def respond_to_update; respond_to_action('update'); end
        def respond_to_destroy; respond_to_action('destroy'); end
      
        def respond_to_action(action)
          respond_to do |format|
            [:html, :js].each do |name| # , :mobile
              format.send(name) { send("respond_to_#{name}_on_#{action}") if respond_to?("respond_to_#{name}_on_#{action}") }
            end
          end
        end
      
        def resource_created?
          @resource.errors.empty?
        end
      
        def resource_destroyed?
          @resource.errors.empty?
        end
      
        def resource_updated?
          @resource.errors.empty?
        end
      
        def respond_to_html_on_create
          return respond_to_html_on_create_success if resource_created?
          respond_to_html_on_create_failure
        end
 
        def respond_to_html_on_create_failure
          render :action => 'new'
        end
      
        def respond_to_html_on_create_success
          redirect_to resource_path(@resource)
        end
 
        def respond_to_html_on_destroy
          return respond_to_html_on_destroy_success if resource_destroyed?
          respond_to_html_on_destroy_failure
        end
 
        def respond_to_html_on_destroy_failure
          redirect_to :back
        end
 
        def respond_to_html_on_destroy_success
          redirect_to resources_path
        end
 
        def respond_to_html_on_update
          return respond_to_html_on_update_success if resource_updated?
          respond_to_html_on_update_failure
        end
 
        def respond_to_html_on_update_failure
          redirect_to :back
        end
 
        def respond_to_html_on_update_success
          redirect_to resource_path(@resource)
        end
      
        # URL helpers
      
        # def new_resource_path(*args)
        #   args.unshift(resource_parent) if resource_parent_class
        #   __send__("new_#{resource_route_prefix}#{resource_name}_path", *args)
        # end
        #       
        # def edit_resource_path(*args)
        #   args.unshift(resource_parent) if resource_parent_class
        #   __send__("edit_#{resource_route_prefix}#{resource_name}_path", *args)
        # end
        #       
        # def resource_path(*args)
        #     args.unshift(resource_parent) if resource_parent_class
        #   __send__("#{resource_route_prefix}#{resource_name}_path", *args)
        # end
        # 
        # def resources_path(*args)
        #   __send__("#{resource_route_prefix}#{resource_name.pluralize}_path", *args)
        # end
      
        # def resource_route_prefix
        #   prefixes = []
        #   prefixes << resource_namespace if resource_namespace
        #   prefixes << resource_parent_name if resource_parent_class
        #   prefixes.empty? ? '' : prefixes.join('_') + '_'
        # end
      
        def allowed_params
          []
        end
        
        # def report(message, level = :notice)
        #   if request.xhr?
        #     (flash.now[level] ||= []) << message
        #   else
        #     (flash[level] ||= []) << message
        #   end
        # end

        def siesta_config(name)
          self.class.siesta_config[name.to_sym]
        end
        
      end
    end
  end
end