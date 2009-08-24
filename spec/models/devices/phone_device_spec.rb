

require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Device::PhoneDevice do

  describe 'validations' do
    before(:each) do
      @phone_device = Factory(:phone_device)
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

  end
end
