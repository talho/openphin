module FeatureHelpers
  module AuthenticationMethods
    attr_reader :current_user
    
    def login_as(user)
      visit sign_in_path
      Then %Q{I should see "Email"}
      fill_in "Email", :with => user.email
      fill_in "Password", :with => "Password1"
      click_button "Sign in"
      @current_user = user
    end
    
    def unset_current_user
      @current_user = nil
    end
  end
end

World(FeatureHelpers::AuthenticationMethods)
