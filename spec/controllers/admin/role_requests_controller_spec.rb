require File.dirname(__FILE__) + '/../../spec_helper'

describe Admin::RoleRequestsController do
  should_require_login_on_all_actions
  
  describe "a logged in user" do
    before do
      @current_user = login_as_user
    end
    
    should_require_admin_on_all_actions "@current_user"
  end
  
end
