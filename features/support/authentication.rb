module FeatureHelpers
  module AuthenticationMethods
    attr_reader :current_user
    
    def login_as(user)
      begin
        visit sign_in_path
        Then %Q{I should see "Sign up"}
        fill_in "Email", :with => user.email
        fill_in "Password", :with => "Password1"
        click_button "Sign in"
        @current_user = user
      rescue Timeout::Error
        sleep 5
        login_as(user)
      end
    end
    
    def unset_current_user
      @current_user = nil
    end
  end
end

World(FeatureHelpers::AuthenticationMethods)
