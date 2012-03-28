

require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Device::FaxDevice do

  describe 'validations' do
    before(:each) do
      @jurisdiction = FactoryGirl.create(:jurisdiction)
      FactoryGirl.create(:jurisdiction).move_to_child_of(@jurisdiction)
      @fax = FactoryGirl.create(:fax_device)
    end
    it "should be valid" do
      @fax.should be_valid
    end

    it "should not be valid with a bad phone number" do
      @fax.fax = "1"
      @fax.should_not be_valid
    end

    it "should not be valid with letters in the phone number" do
      @fax.fax = "abcdefg1234"
      @fax.should_not be_valid
    end

  end
end
