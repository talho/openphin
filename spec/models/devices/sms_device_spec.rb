

require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Device::SmsDevice do

  describe 'validations' do
    before(:each) do
      @jurisdiction = FactoryGirl.create(:jurisdiction)
      FactoryGirl.create(:jurisdiction).move_to_child_of(@jurisdiction)
      @sms = FactoryGirl.create(:sms_device)
    end
    it "should be valid" do
      @sms.should be_valid
    end

    it "should not be valid with a bad sms number" do
      @sms.sms = "1"
      @sms.should_not be_valid
    end

    it "should not be valid with letters in the sms number" do
      @sms.sms = "abcdefg1234"
      @sms.should_not be_valid
    end

  end
end
