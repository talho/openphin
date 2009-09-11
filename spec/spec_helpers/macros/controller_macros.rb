module SpecHelpers
  module ControllerHelpers
    def stub_filters_of_type(type, options)
      controller.class.send("#{type}_filters").each do |filter_name|
        next if options[:except].respond_to?(:include?) && options[:except].include?(filter_name)
        next if options[:except] == filter_name
        next if filter_name.is_a?(Proc)
        controller.stub!(filter_name).and_return(true)
      end    
    end
  
    def stub_before_filters!(options = {})
      stub_filters_of_type(:before, options)
    end

    def stub_after_filters!(options = {})
      stub_filters_of_type(:after, options)
    end
  end
  
  module ControllerMacros
    def should_require_admin_on_all_actions(user_str, params={}, options={})
      ActionController::Routing::Routes.add_route ":controller/:action"
      described_type.action_methods.each do |action|
        %w( get post put delete ).each do |verb|
          should_require_admin_role user_str, verb, action, params, options
        end
      end
    end
    
    def should_require_admin_role(user_str, http_method, action, params={}, options={})
      describe "#{http_method} ##{action} requires the admin role" do
        before do
          @role = Role.admin
          stub_before_filters! :except => [:login_required, :admin_required, :admin_or_self_required]
        end
      
        describe "when the user does not have the admin role" do
          it "does not call ##{action} action" do
            user = instance_variable_get(user_str)
            user.role_memberships.delete_all
            controller.should_not_receive(action)
            send http_method, action, params
          end
        end

        describe "when the user has the admin role" do
          it "calls the ##{action} action" do
            user = instance_variable_get(user_str)
            Factory(:role_membership, :role => @role, :user => user)
            controller.should_receive(action)
            send http_method, action, params
          end
        end
      end
    end
    
    def should_require_login_on_all_actions(params={}, options={})
      ActionController::Routing::Routes.add_route ":controller/:action"
      described_type.action_methods.each do |action|
        %w( get post put delete ).each do |verb|
          should_require_login verb, action, params, options
        end
      end
    end
    
    def should_require_login(http_method, action, params={}, options={})
      describe "#{http_method} ##{action} requires login" do
        before do
          stub_before_filters! :except => :login_required
        end
      
        describe "when not logged in" do
          it "does not call the ##{action} action" do
            controller.should_not_receive(action)
            send http_method, action, params
          end
        end
  
        describe "when logged in" do
          before do
            login_as_user
          end
        
          it "calls the ##{action} action" do
            controller.should_receive(action)
            send http_method, action, params
          end
        end
      end
    end

  end
end