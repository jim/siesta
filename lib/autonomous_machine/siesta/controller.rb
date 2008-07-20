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
            before_filter :load_resource_chain
          end
          
          if options[:actions].respond_to? :each
            self.siesta_config[:public_actions] = options[:actions]
          elsif options[:actions].is_a? Symbol
            if options[:actions] == :all
              self.siesta_config[:public_actions]= [:index, :new, :create, :update, :edit, :destroy, :show]
            else
              self.siesta_config[:public_actions]= [options[:public]]
            end
          end
          
          public *self.siesta_config[:public_actions] unless self.siesta_config[:public_actions].nil?
          
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
          send_or_default("new_#{siesta_config(:resource)}") do
            source = resource_source(siesta_config(:resource))
            if source.respond_to?(:proxy_target)
              resource = source.build(resource_params)
            else
              resource = source.new(resource_params)
            end
            instance_variable_set("@#{siesta_config(:resource)}", resource)
          end
        end
      
        def create_resource
          send_or_default("create_#{siesta_config(:resource)}") do
            new_resource
            resource = instance_variable_get("@#{siesta_config(:resource)}")
            resource.attributes=resource_params(create_params)
            resource.save
          end
        end
        
        def update_resource
          send_or_default("update_#{siesta_config(:resource)}") do
            resource = instance_variable_get("@#{siesta_config(:resource)}")
            resource.attributes=resource_params(update_params)
            resource.save
          end
        end
        
        def destroy_resource
          send_or_default("destroy_#{siesta_config(:resource)}") do
            resource = instance_variable_get("@#{siesta_config(:resource)}")
            resource.destroy
          end
        end

        def load_resource
          load_object(siesta_config(:resource))
        end

        def load_resources
          load_collection(siesta_config(:resource))
        end
      
        def load_object(name)
          object = send_or_default("load_#{name}") do
            resource_source(name).find(resource_id(name))
          end
          instance_variable_set("@#{name}", object)
        end      
      
        def load_collection(name)
          collection = send_or_default("load_#{name.pluralize}") do
            resource_source(name).paginate(:page => params[:page])
          end
          instance_variable_set("@#{name.pluralize}", collection)
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
      
        def create_params
          {}
        end
        
        def update_params
          {}
        end
      
        def resource_params(attributes={})
          (params[siesta_config(:resource)] || {}).reject{|k, v| !allowed_params.map(&:to_s).include?(k) }.merge(attributes)
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
          send_or_default("#{siesta_config(:resource)}_created?") do
            instance_variable_get("@#{siesta_config(:resource)}").errors.empty?
          end
        end
              
        def resource_destroyed?
          send_or_default("#{siesta_config(:resource)}_destroyed?") do
            instance_variable_get("@#{siesta_config(:resource)}").errors.empty?
          end
        end
              
        def resource_updated?
          send_or_default("#{siesta_config(:resource)}_updated?") do
            instance_variable_get("@#{siesta_config(:resource)}").errors.empty?
          end
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
          render :action => 'show'
        end
 
        def respond_to_html_on_destroy_success
          redirect_to resources_path
        end
 
        def respond_to_html_on_update
          return respond_to_html_on_update_success if resource_updated?
          respond_to_html_on_update_failure
        end
 
        def respond_to_html_on_update_failure
          render :action => 'edit'
        end
 
        def respond_to_html_on_update_success
          redirect_to resource_path(@resource)
        end
      
        # URL helpers
      
        def new_resource_path(*args)
          send("new_#{resource_route_prefix}#{siesta_config(:resource)}_path", *(resource_route_arguments.concat(args)))
        end
              
        def edit_resource_path(*args)
          send("edit_#{resource_route_prefix}#{siesta_config(:resource)}_path", *(resource_route_arguments.concat(args)))
        end
              
        def resource_path(*args)
          send("#{resource_route_prefix}#{siesta_config(:resource)}_path", *(resource_route_arguments.concat(args)))
        end
        
        def resources_path(*args)
          send("#{resource_route_prefix}#{siesta_config(:resource).pluralize}_path", *(resource_route_arguments.concat(args)))
        end
      
        def resource_route_arguments
          send_or_default("#{siesta_config(:resource)}_route_prefix") do
            siesta_config(:resource_chain).map do |name|
              instance_variable_get("@#{name}")
            end
          end
        end
      
        def resource_route_prefix
          send_or_default("#{siesta_config(:resource)}_route_prefix") do
            siesta_config(:resource_chain).map{|name| "#{name}_"}.join
          end
        end
      
        def allowed_params
          []
        end
        
        def report(message, level = :notice)
          if request.xhr?
            (flash.now[level] ||= []) << message
          else
            (flash[level] ||= []) << message
          end
        end

        def siesta_config(name)
          self.class.siesta_config[name.to_sym]
        end
        
      end
    end
  end
end