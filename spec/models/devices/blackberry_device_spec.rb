

require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Device::BlackberryDevice do

  describe 'validations' do
    before(:each) do
      @jurisdiction = FactoryGirl.create(:jurisdiction)
      FactoryGirl.create(:jurisdiction).move_to_child_of(@jurisdiction)
      @blackberry = FactoryGirl.create(:blackberry_device)
    end
    it "should be valid" do
      @blackberry.should be_valid
    end

    it "should not be valid with less than 8 characters" do
      @blackberry.blackberry = "1234567"
      @blackberry.should_not be_valid
    end

    it "should not be valid with more than 8 characters" do
      @blackberry.blackberry = "123456789"
      @blackberry.should_not be_valid
    end

    it "should be valid with hex characters" do
      @blackberry.blackberry="abcdef12"
      @blackberry.should be_valid
    end

    it "should not be valid with non hex characters in the number" do
      @blackberry.blackberry = "zxvg2345"
      @blackberry.should_not be_valid
    end

  end
end
