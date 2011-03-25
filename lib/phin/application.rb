module Phin
  module Application
    def self.included(controller)
      controller.send(:include, Helpers)
      controller.send(:include, InstanceMethods)
      controller.extend ClassMethods
    end

    def self.eval_if_plugin_present(plugin_name, &block)
      loc = File.join(Rails.root, "vendor", "plugins", plugin_name.to_s)
      if File.exists?(loc) && (!File.directory?(loc) || Dir.entries(loc).count > 2)
        begin
          yield block
        rescue => e
          raise unless e.message.index(plugin_name.to_s)
        end
      end
    end

    module ClassMethods
      attr_accessor_with_default(:access_roles){ Array.new }

      def self.extended(controller)
        controller.before_filter :verify_roles
      end

      def phin_application(appname, options = nil)
        applications[appname] = OpenStruct.new if applications[appname].nil?
        app=applications[appname]
        if options[:entry]
          raise "Cannot define multiple entry points for a PhinApplication" unless app.entry.nil?
          if options[:entry].is_a?(Class)
            raise "Entry point does not implement Phin::Application::ClassMethods" unless
                options[:entry].is_a?(Phin::Application::ClassMethods)
            entrypoint=options[:entry]
          elsif options[:entry].is_a?(String) || options[:entry].is_a?(Symbol)
            entrypoint=options[:entry].constantize
          else
            entrypoint = self
          end
          applications[appname].entry = entrypoint
        end
      end

      def register_phin_application
      end

      def role_required(role_or_roles)
        access_roles.concat(role_or_roles.is_a?(String) ? [role_or_roles] : role_or_roles)
      end
    end

    module InstanceMethods
      def verify_roles
        return true if signed_in? and current_user.roles.detect{|r| self.class.access_roles.detect{|ar| ar == r}}
        false
      end
    end

    module Helpers
      def self.included(controller)
        controller.helper_method :define_toolbar
        controller.helper_method :toolbar_item
      end

      def define_toolbar(toolbar_name, options = nil, &block)
        raise ArgumentError, "Missing block" unless block_given?
        content_tag :ul, capture(&block)
      end

      def toolbar_item(item_text, url_options, html_options=nil)
        item_text=link_to(item_text, url_options) if url_options.is_a?(Hash)
        content_tag :li, item_text, html_options
      end
    end
  end
end
