module FeatureHelpers
  module AuthenticationMethods
    attr_reader :current_user
    
    def login_as(user)
        visit sign_in_path
        fill_in "Email", :with => user.email
        fill_in "Password", :with => "Password1"
        click_button "Sign in"
        @current_user = user
        
        #this used to rescue from a timeout error and repeat endlessly, but I think we're going to let it timeout and throw an exception instead.
    end
    
    def unset_current_user
      @current_user = nil
    end
  end
end

World(FeatureHelpers::AuthenticationMethods)
