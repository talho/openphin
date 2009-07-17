require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe OrganizationsController do

  #Delete these examples and add some real ones
  it "should use OrganizationsController" do
    controller.should be_an_instance_of(OrganizationsController)
  end


  describe "GET 'new'" do
    it "should be successful" do
      get 'new'
      response.should be_success
    end
  end
end
