module SpecHelpers
  module ControllerHelpers
    def login_as(user)
      request.session[:user_id] = user ? user.id : nil
      User.stub!(:find_by_id).with(user.id).and_return(user)
    end
  
    def login_as_user
      login_as stub_model(User, Factory.attributes_for(:user))
    end  
  end
end