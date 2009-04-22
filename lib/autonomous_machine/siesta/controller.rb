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
          options = args.extract_options!
        
          self.siesta_config = {}
        
          resources = args.map{|r| r.to_s.singularize.underscore}
        
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
          
          resourcified_methods = Module.new
          
          name = self.siesta_config[:resource].gsub(/([a-z_]+\/)/, '')
                    
          %w(new create destroy update destroy).each do |prefix|
            resourcified_methods.module_eval "protected; def #{prefix}_#{name}; #{prefix}_resource; end", __FILE__, __LINE__
          end

          resourcified_methods.module_eval "protected; def load_#{name.pluralize}; load_collection('#{name}'); end", __FILE__, __LINE__
          resourcified_methods.module_eval "protected; def #{name.pluralize}_params; resource_params; end", __FILE__, __LINE__
          resourcified_methods.module_eval "protected; def #{name}_order; nil; end", __FILE__, __LINE__
          resourcified_methods.module_eval "protected; def #{name}_includes; nil; end", __FILE__, __LINE__
          resourcified_methods.module_eval "protected; def #{name}_conditions; nil; end", __FILE__, __LINE__
          %w(created updated destroyed).each do |action|
            resourcified_methods.module_eval "protected; def #{name}_#{action}?; resource_#{action}?('#{name}'); end", __FILE__, __LINE__
          end
          
          (self.siesta_config[:resource_chain] + [self.siesta_config[:resource]]).each do |resource|
            demodulized = resource.gsub(/([a-z_]+\/)/, '')
            resourcified_methods.module_eval "protected; def load_#{demodulized}; load_object('#{demodulized}'); end", __FILE__, __LINE__
            resourcified_methods.module_eval "protected; def #{demodulized}_source; resource_source('#{demodulized}'); end", __FILE__, __LINE__
          end
          
          instance_eval do
            include resourcified_methods
          end
        end
        
        alias :siesta :restful_actions_for
        
      end
    
      module InstanceMethods
      
        private
      
        def create
          send("create_#{demodulize(siesta_config(:resource))}")
          report message_for_create_success(@resource) if send("#{demodulize(siesta_config(:resource))}_created?")
          respond_to_create
        end
      
        def destroy
          send("load_#{demodulize(siesta_config(:resource))}")
          send("destroy_#{demodulize(siesta_config(:resource))}")
          report message_for_destroy_success(@resource) if send("#{demodulize(siesta_config(:resource))}_destroyed?")
          respond_to_destroy
        end
      
        def edit
          send("load_#{demodulize(siesta_config(:resource))}")
          respond_to_edit
        end
      
        def index
          send("load_#{demodulize(siesta_config(:resource)).pluralize}")
          respond_to_index
        end
      
        def new
          send("new_#{demodulize(siesta_config(:resource))}")
          respond_to_new
        end
      
        def show
          send("load_#{demodulize(siesta_config(:resource))}")
          respond_to_show
        end
      
        def update
          send("load_#{demodulize(siesta_config(:resource))}")
          send("update_#{demodulize(siesta_config(:resource))}")
          report message_for_update_success(@resource) if send("#{demodulize(siesta_config(:resource))}_updated?")
          respond_to_update
        end
      
        protected
      
        def new_resource
          source = send("#{demodulize(siesta_config(:resource))}_source")
          if source.respond_to?(:proxy_target)
            resource = source.build(resource_params(create_params))
          else
            resource = source.new(resource_params(create_params))
          end
          instance_variable_set("@#{demodulize(siesta_config(:resource))}", resource)
        end
      
        def create_resource
          send("new_#{demodulize(siesta_config(:resource))}")
          resource = instance_variable_get("@#{demodulize(siesta_config(:resource))}")
          resource.save
        end
        
        def update_resource
          resource = instance_variable_get("@#{demodulize(siesta_config(:resource))}")
          resource.attributes=resource_params(update_params)
          resource.save
        end
        
        def destroy_resource
          resource = instance_variable_get("@#{demodulize(siesta_config(:resource))}")
          resource.destroy
        end
      
        def load_object(name)
          object = send("#{name}_source").find(resource_id(name))
          instance_variable_set("@#{name}", object)
        end      
      
        def load_collection(name)
          collection = send("#{name}_source").paginate(:page => params[:page], :order => send("#{name}_order"), :include => send("#{name}_includes"), :conditions => send("#{name}_conditions"))
          instance_variable_set("@#{name.pluralize}", collection)
        end
      
        def resource_source(name)
          if name == demodulize(siesta_config(:resource)) && !siesta_config(:resource_chain).empty?
            instance_variable_get("@#{demodulize(siesta_config(:resource_chain).last)}").send(demodulize(siesta_config(:resource)).pluralize)
          else
            match = siesta_config(:resource_chain).find do |r|
              demodulize(r) == name
            end
            if match
              if demodulize(siesta_config(:resource_chain).first) != name
                var_name = "@#{demodulize(siesta_config(:resource_chain)[siesta_config(:resource_chain).index(match)-1])}"
                instance_variable_get(var_name).send(name.pluralize)
              else
                match.classify.constantize
              end
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
          (params[demodulize(siesta_config(:resource))] || {}).merge(attributes)
        end
      
        def load_resource_chain
          siesta_config(:resource_chain).each do |name|
            send("load_#{demodulize(name)}")
          end
        end
      
        def resource_id(name)
          id = name == demodulize(siesta_config(:resource)) ? params[:id] : params[name + '_id']
          raise MissingResourceId.new("No ID found for #{name}") unless id
          id
        end
      
        def message_for_create_success(resource); "The #{siesta_config(:resource)} has been created."; end
        def message_for_update_success(resource); "Your changes have been saved."; end
        def message_for_destroy_success(resource); "The #{siesta_config(:resource)} has been deleted."; end
      
        def resource_created?(name); instance_variable_get("@#{name}").errors.empty?; end
        def resource_destroyed?(name); instance_variable_get("@#{name}").errors.empty?; end
        def resource_updated?(name); instance_variable_get("@#{name}").errors.empty?; end
      
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
      
        def respond_to_html_on_create
          return respond_to_html_on_create_success if send("#{demodulize(siesta_config(:resource))}_created?")
          respond_to_html_on_create_failure
        end
 
        def respond_to_html_on_create_failure
          render :action => 'new'
        end
      
        def respond_to_html_on_create_success
          redirect_to resource_path(instance_variable_get("@#{demodulize(siesta_config(:resource))}"))
        end
 
        def respond_to_html_on_destroy
          return respond_to_html_on_destroy_success if send("#{demodulize(siesta_config(:resource))}_destroyed?")
          respond_to_html_on_destroy_failure
        end
 
        def respond_to_html_on_destroy_failure
          render :action => 'show'
        end
 
        def respond_to_html_on_destroy_success
          redirect_to resources_path
        end
 
        def respond_to_html_on_update
          return respond_to_html_on_update_success if send("#{demodulize(siesta_config(:resource))}_updated?")
          respond_to_html_on_update_failure
        end
 
        def respond_to_html_on_update_failure
          render :action => 'edit'
        end
 
        def respond_to_html_on_update_success
          redirect_to resource_path(instance_variable_get("@#{demodulize(siesta_config(:resource))}"))
        end
      
        # URL helpers
      
        def new_resource_path(*args)
          send("new_#{resource_route_prefix}#{demodulize(siesta_config(:resource))}_path", *(resource_route_arguments.concat(args)))
        end
              
        def edit_resource_path(*args)
          send("edit_#{resource_route_prefix}#{demodulize(siesta_config(:resource))}_path", *(resource_route_arguments.concat(args)))
        end
              
        def resource_path(*args)
          send("#{resource_route_prefix}#{demodulize(siesta_config(:resource))}_path", *(resource_route_arguments.concat(args)))
        end
        
        def resources_path(*args)
          send("#{resource_route_prefix}#{demodulize(siesta_config(:resource)).pluralize}_path", *(resource_route_arguments.concat(args)))
        end
      
        def resource_route_arguments
          siesta_config(:resource_chain).map do |name|
            instance_variable_get("@#{demodulize(name)}")
          end
        end
      
        def resource_route_prefix
          siesta_config(:resource_chain).map{|name| "#{demodulize(name)}_"}.join
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
        
        def demodulize(namespaced_resource_name)
          namespaced_resource_name.gsub(/([a-z_]+\/)/, '')
        end
      end
    end
  end
end