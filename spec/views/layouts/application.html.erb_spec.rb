require File.dirname(__FILE__) + '/../../spec_helper'

describe "layouts/application.html.erb" do
  context "when a user is signed in" do
    before(:each) do
      @user = mock_model(User).as_null_object
      template.stubs(:current_user).returns @user
      template.stubs(:signed_in?).returns true
    end
    
    it "should have a link to the edit the user profile" do
      render "layouts/application.html.erb"
      response.should have_selector("a", :href => edit_user_profile_path(@user))
    end
  end
end
