require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Device::PhoneDevice do

  describe 'validations' do
    before(:each) do
      @jurisdiction = FactoryGirl.create(:jurisdiction)
      FactoryGirl.create(:jurisdiction).move_to_child_of(@jurisdiction)
      @phone_device = FactoryGirl.create(:phone_device)
    end
    it "should be valid" do
      @phone_device.should be_valid
    end

    it "should not be valid with a bad phone number" do
      @phone_device.phone = "1"
      @phone_device.should_not be_valid
    end

    it "should not be valid with letters in the phone number" do
      @phone_device.phone = "abcdefg1234"
      @phone_device.should_not be_valid
    end

    it "cannot be created more than once per user" do
      @user = @phone_device.user
      @phone_device.phone = "5125657931"
      @phone_device.should be_valid
      @phone_device.save!
      @phone_device = Factory.build(:phone_device, :user => @user, :phone => "5125657931")
      @phone_device.should_not be_valid
    end

  end
end
