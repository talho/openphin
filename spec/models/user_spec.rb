# == Schema Information
#
# Table name: users
#
#  id                 :integer         not null, primary key
#  last_name          :string(255)
#  phin_oid           :string(255)
#  description        :text
#  display_name       :string(255)
#  first_name         :string(255)
#  email              :string(255)
#  preferred_language :string(255)
#  title              :string(255)
#  created_at         :datetime
#  updated_at         :datetime
#  encrypted_password :string(128)
#  salt               :string(128)
#  token              :string(128)
#  token_expires_at   :datetime
#  email_confirmed    :boolean         not null
#

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe User do
  
  describe "validations" do
    before(:each) do
      @user = Factory.build(:user)
    end
    
    it "should be valid" do
      @user.valid?.should be_true
    end
    
    it "should not be valid without an email" do
      @user.email = ""
      @user.valid?.should be_false
    end
    
    it "should not be valid without a first name" do
      @user.first_name = ""
      @user.valid?.should be_false
    end

    it "should not be valid without a last name" do
      @user.last_name = ""
      @user.valid?.should be_false
    end

    it "should be invalid if a Person already exists with same email" do
      Factory(:user, :email => "joe@example.com")
      @user.email = "joe@example.com"
      @user.valid?.should be_false
    end
  end

  should_make_fields_accessible :first_name, :last_name, :display_name, :description, :preferred_language, :title
    
  describe "phin_oid" do
    it "should be generated on create" do
      Factory(:user).phin_oid.should_not be_blank
    end
    
    it "should not change when saving" do
      person = Factory(:user)
      lambda {
        person.update_attributes! :first_name => 'changed'
      }.should_not change { person.phin_oid }
    end
    
    it "should not allow assignment" do
      person = Factory(:user)
      lambda { person.phin_oid = 1 }.should raise_error
    end
  end
end
