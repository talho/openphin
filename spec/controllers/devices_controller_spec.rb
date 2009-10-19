require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe DevicesController do
  before(:each) do
    @jurisdiction =Factory(:jurisdiction)
    Factory(:jurisdiction).move_to_child_of(@jurisdiction)
  end

  #Delete these examples and add some real ones
  it "should use DevicesController" do
    controller.should be_an_instance_of(DevicesController)
  end

  it "should destroy when owner is logged in" do
    user = Factory(:user)
    device = Factory(:email_device, :user => user)
    login_as(user)
    lambda {
      delete(:destroy, {:user_id => user.id, :id => device.id}).session["flash"].should be_blank
    }.should change(Device, :count).by(-1)
  end

  it "should not destroy when another user is logged in" do
    user = Factory(:user)
    user2 = Factory(:user)
    device = Factory(:email_device, :user => user2)
    login_as(user)
    lambda {
      delete(:destroy, {:user_id => user2.id, :id => device.id}).session["flash"][:error].should_not be_blank
    }.should_not change(Device, :count)
  end

  it "should destroy when admin is logged in" do
    user = Factory(:user)
    RoleMembership.create(:role => Role.admin, :jurisdiction => @jurisdiction, :user => user)
    user.reload
    device_ct=Device.all.size
    user2 = Factory(:user)
    RoleMembership.create(:role => Factory(:role), :jurisdiction => @jurisdiction, :user => user2)
    user.reload
    device = user2.devices.first
    login_as(user)
    delete(:destroy, {:user_id => user2.id, :id => device.id}).session["flash"].should be_nil
    Device.all.size.should == device_ct
  end

end
