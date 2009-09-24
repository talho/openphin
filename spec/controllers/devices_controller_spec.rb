require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe DevicesController do
 
  #Delete these examples and add some real ones
  it "should use DevicesController" do
    controller.should be_an_instance_of(DevicesController)
  end

  it "should destroy when owner is logged in" do
    device_ct=Device.all.size
    user = Factory(:user)
    device = user.devices.first
    login_as(user)
    delete(:destroy, {:user_id => user.id, :id => device.id}).session["flash"].should be_nil
    Device.all.size.should == device_ct
  end

  it "should not destroy when another user is logged in" do
    user = Factory(:user)
    user2 = Factory(:user)
    device = user2.devices.first
    login_as(user)
    delete(:destroy, {:user_id => user2.id, :id => device.id}).session["flash"][:error].should_not be_blank
    Device.all.size.should_not == 0
    device.destroy
  end

  it "should destroy when admin is logged in" do
    user = Factory(:user)
    RoleMembership.create(:role => Role.admin, :jurisdiction => Factory(:jurisdiction), :user => user)
    device_ct=Device.all.size
    user2 = Factory(:user)
    device = user2.devices.first
    login_as(user)
    delete(:destroy, {:user_id => user2.id, :id => device.id}).session["flash"].should be_nil
    Device.all.size.should == device_ct
  end

end
