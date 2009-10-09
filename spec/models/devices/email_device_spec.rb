
require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Device::EmailDevice do
  describe 'validations' do
    before(:each) do
      @jurisdiction = Factory(:jurisdiction)
      Factory(:jurisdiction).move_to_child_of(@jurisdiction)
      @email = Factory(:email_device)
    end
    
    it "should be valid" do
      @email.should be_valid
    end

    it "should not be valid without an @" do
      @email.email_address = "someusername"
      @email.should_not be_valid
    end

    it "should not be valid without a TLD" do
      @email.email_address = "user@somedomain"
      @email.should_not be_valid
    end

    it "should not be valid without a username" do
      @email.email_address = "@domain.com"
      @email.should_not be_valid
    end

    it "should not be valid with spaces" do
      @email.email_address = "some user@mydomain.com"
      @email.should_not be_valid
    end
    it "should not be valid without a domain" do
      @email.email_address = "someuser@.com"
      @email.should_not be_valid
    end

    it "should not be valid with two dots consecutively" do
      @email.email_address = "k@g..com"
    end
  end
end