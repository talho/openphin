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
  
  describe "creating a user" do
    before(:each) do
      Role.find_or_create_by_name("Public")
    end
    
    context "when the user is created with role requests" do
      it "should create a public role membership for the jurisdiction of the first role request" do
        jurisdiction = Factory(:jurisdiction)
        user = Factory.build(:user)
        user.role_requests = [Factory.build(:role_request, :jurisdiction => jurisdiction, :requester => user)]
        user.save!
        public_membership = user.role_memberships.detect do |membership|
          membership.jurisdiction == jurisdiction && membership.role == Role.find_by_name!("Public")
        end
         public_membership.should_not be_nil
      end
    end
    
    context "when the user is created without any role requests" do
      it "should not assign a public role membership" do
        user = Factory(:user, :role_requests => [])
        user.role_memberships.should be_empty
      end
    end
  end

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
  describe "#is_admin_for" do
    before(:each) do
      @user = Factory(:user)
      role = Role.admin || Factory(:role, :name => Role::ADMIN)
      @jurisdiction = Factory(:jurisdiction)
      Factory(:role_membership, :jurisdiction => @jurisdiction, :role => role, :user => @user)
    end
    it "should return true if the user is an admin for the given jurisdiction" do
      @user.is_admin_for?(@jurisdiction).should == true
    end
    it "should return false if the user is not an admin for the given jurisdiction" do
      j2=Factory(:jurisdiction)
      @user.is_admin_for?(j2).should == false
    end
  end
end
