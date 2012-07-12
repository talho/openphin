# == Schema Information
#
# Table name: users
#
#  id                 :integer(4)      not null, primary key
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
#  email_confirmed    :boolean(1)      default(FALSE), not null
#  phone              :string(255)
#  delta              :boolean(1)      default(TRUE), not null
#  credentials        :text
#  bio                :text
#  experience         :text
#  employer           :string(255)
#  photo_file_name    :string(255)
#  photo_content_type :string(255)
#  public             :boolean(1)
#  photo_file_size    :integer(4)
#  photo_updated_at   :datetime
#  deleted_at         :datetime
#  deleted_by         :string(255)
#  deleted_from       :string(24)
#  home_phone         :string(255)
#  mobile_phone       :string(255)
#  fax                :string(255)
#

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe User do
  
  describe "validations" do
    before(:each) do
      @jurisdiction = FactoryGirl.create(:jurisdiction)
      FactoryGirl.create(:jurisdiction).move_to_child_of(@jurisdiction)
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
      FactoryGirl.create(:user, :email => "joe@example.com")
      @user.email = "joe@example.com"
      @user.valid?.should be_false
      @user.errors["email"].include?("address is already being used on another user account.  If you have forgotten your password, please visit the sign in page and click the Forgot password? link.").should be_true
    end
  end

  should_make_fields_accessible :first_name, :last_name, :display_name, :description, :preferred_language, :title
  
  describe "creating a user" do
    before(:each) do
      @jurisdiction = FactoryGirl.create(:jurisdiction)
      FactoryGirl.create(:jurisdiction).move_to_child_of(@jurisdiction)
      Role.find_or_create_by_name("Public")
    end
    
    context "when the user is created with role requests" do
      it "should create a public role membership for the jurisdiction of the first role request" do
        jurisdiction = FactoryGirl.create(:jurisdiction)
        user = Factory.build(:user)
        user.role_requests = [Factory.build(:role_request, 
            :role => FactoryGirl.create(:role, public: false), 
            :jurisdiction => jurisdiction, :user => user, :requester => user)]
        user.save!
        user.reload
        public_membership = user.role_memberships.detect do |membership|
          membership.jurisdiction == jurisdiction && membership.role == Role.find_by_name!("Public")
        end
         public_membership.should_not be_nil
      end
    end
    
    context "when the user is created without any role requests" do
      it "assign one public role membership" do
        @jurisdiction=FactoryGirl.create(:jurisdiction)
        FactoryGirl.create(:jurisdiction).move_to_child_of(@jurisdiction)
        user = FactoryGirl.create(:user, :role_requests => [])
        user.role_memberships.size.should == 1
      end
    end
  end

  describe "phin_oid" do
    before(:each) do
      @jurisdiction = FactoryGirl.create(:jurisdiction)
      FactoryGirl.create(:jurisdiction).move_to_child_of(@jurisdiction)      
    end
    it "should be generated on create" do
      FactoryGirl.create(:user).phin_oid.should_not be_blank
    end
    
    it "should not change when saving" do
      person = FactoryGirl.create(:user)
      lambda {
        person.update_attributes! :first_name => 'changed'
      }.should_not change { person.phin_oid }
    end
    
    it "should not allow assignment" do
      person = FactoryGirl.create(:user)
      lambda { person.phin_oid = 1 }.should raise_error
    end
  end
  
  describe "#is_admin_for?" do
    before(:each) do
      parent = FactoryGirl.create(:jurisdiction)
      @jurisdiction = FactoryGirl.create(:jurisdiction)
      @jurisdiction.move_to_child_of(parent)
      @user = FactoryGirl.create(:user)
      FactoryGirl.create(:role_membership, :jurisdiction => @jurisdiction, :role => Role.admin, :user => @user)
      @user.reload
    end
    
    it "should return true if the user is an admin for the given jurisdiction" do
      @user.is_admin_for?(@jurisdiction).should == true
    end
    
    it "should return false if the user is not an admin for the given jurisdiction" do
      j2=FactoryGirl.create(:jurisdiction)
      j2.move_to_child_of(@jurisdiction.parent)
      @user.is_admin_for?(j2).should == false
    end
  end
  
  describe "display_name" do
    before(:each) do
      @jurisdiction = FactoryGirl.create(:jurisdiction)
      FactoryGirl.create(:jurisdiction).move_to_child_of(@jurisdiction)
    end

    it "should default to full name if display name not specified" do
      user = User.create(:first_name => 'Brandon', :last_name => 'Keepers', :email => "brandon@example.com", :password => "Password1")
      user.display_name.should == 'Brandon Keepers'
    end
    
    it "should use display name if specified" do
      user = User.new(:first_name => 'Brandon', :last_name => 'Keepers', :display_name => 'bkeepers')
      user.display_name.should == 'bkeepers'
    end
  end
  
  describe "alerter?" do
    before(:each) do
      @jurisdiction = FactoryGirl.create(:jurisdiction)
      FactoryGirl.create(:jurisdiction).move_to_child_of(@jurisdiction)
    end

    it "should return false if user does not have any roles" do
      FactoryGirl.create(:user, :role_memberships => []).alerter?.should be_false
    end

    it "should return false if user does not have an alerter role" do
      user = FactoryGirl.create(:user, :role_memberships => [])
      FactoryGirl.create(:role_membership, :role => FactoryGirl.create(:role, :alerter => false), :user => user)
      user.alerter?.should be_false
    end

    it "should return true if user has an alerter role" do
      user = FactoryGirl.create(:user, :role_memberships => [])
      FactoryGirl.create(:role_membership, :role => FactoryGirl.create(:role, :alerter => true), :user => user)
      user.alerter?.should be_true
    end
  end
  
  describe "han_alerts_within_jurisdictions" do
    before(:each) do
      @jurisdiction = FactoryGirl.create(:jurisdiction)
      FactoryGirl.create(:jurisdiction).move_to_child_of(@jurisdiction)
    end

    it "should include alerts in user's jurisdictions" do
      user = FactoryGirl.create(:user)
      parent = FactoryGirl.create(:jurisdiction)
      jurisdiction = FactoryGirl.create(:jurisdiction)
      jurisdiction.move_to_child_of parent
      user.jurisdictions << jurisdiction
      role = FactoryGirl.create(:role, :alerter => true)
      User.assign_role(role, jurisdiction, [user])
      alert = FactoryGirl.create(:han_alert, :from_jurisdiction => jurisdiction)
      user.han_alerts_within_jurisdictions.should include(alert)
    end
    
    it "should include alerts in child jurisdictions" do
      user = FactoryGirl.create(:user)
      parent = FactoryGirl.create(:jurisdiction)
      user.jurisdictions << parent
      child = FactoryGirl.create(:jurisdiction)
      child.move_to_child_of parent
      role = FactoryGirl.create(:role, :alerter => true)
      User.assign_role(role, parent, [user])
      alert = FactoryGirl.create(:han_alert, :from_jurisdiction => child)
      user.han_alerts_within_jurisdictions.should include(alert)
    end
    
    it "should not include alerts in other jurisdicitions" do
      parent = FactoryGirl.create(:jurisdiction)
      jurisdiction = FactoryGirl.create(:jurisdiction)
      jurisdiction.move_to_child_of(parent)
      another = FactoryGirl.create(:jurisdiction)
      another.move_to_child_of(parent)
      user = FactoryGirl.create(:user)
      role = FactoryGirl.create(:role, :alerter => true)
      User.assign_role(role, jurisdiction, [user])
      alert = FactoryGirl.create(:han_alert, :from_jurisdiction => another)
      user.han_alerts_within_jurisdictions.should_not include(alert)
    end
  end
  
  it "should create the role membership to the given list of users" do
    @jurisdiction = FactoryGirl.create(:jurisdiction)
    FactoryGirl.create(:jurisdiction).move_to_child_of(@jurisdiction)
    user1 = FactoryGirl.create(:user)
    user2 = FactoryGirl.create(:user)
    role = FactoryGirl.create(:role)
    jurisdiction = FactoryGirl.create(:jurisdiction)
    User.assign_role(role, jurisdiction, [user1, user2])
    jurisdiction.users.should include(user1, user2)
  end
  
  describe "alerter_jurisdictions" do
    before do
      jurisdiction1 = FactoryGirl.create(:jurisdiction)
      jurisdiction2 = FactoryGirl.create(:jurisdiction)
      jurisdiction2.move_to_child_of(jurisdiction1)
      @user = FactoryGirl.create(:user)
      role1 = FactoryGirl.create(:role, :alerter => true)
      role2 = FactoryGirl.create(:role, :alerter => true)
      User.assign_role(role1, jurisdiction1, [@user])
      User.assign_role(role1, jurisdiction2, [@user])
      User.assign_role(role2, jurisdiction2, [@user])
    end
    
    it "should include all the jurisdictions the user is an alerter in" do
      @user.role_memberships.alerter.each do |role_membership|
        @user.alerter_jurisdictions.should include(role_membership.jurisdiction)
      end
    end
    
    it "should not have duplicates" do
      @user.alerter_jurisdictions.should == @user.alerter_jurisdictions.uniq
    end
  end

  describe "adding roles" do
    it "should not allow the same role and jurisdiction to be added twice" do
      jur=FactoryGirl.create(:jurisdiction)
      FactoryGirl.create(:jurisdiction).move_to_child_of(jur)
      user=FactoryGirl.create(:user)
      role=FactoryGirl.create(:role)
      user.role_memberships.create(:role => role, :jurisdiction => jur)
      user.role_memberships.build(:role => role, :jurisdiction => jur)
      user.should_not be_valid
    end
    it "should not allow a role request to duplicate a role" do
      jur=FactoryGirl.create(:jurisdiction)
      FactoryGirl.create(:jurisdiction).move_to_child_of(jur)
      user=FactoryGirl.create(:user)
      role=FactoryGirl.create(:role)
      jur=FactoryGirl.create(:jurisdiction)
      user.role_memberships.create(:role => role, :jurisdiction => jur)
      user.role_requests.build(:role => role, :jurisdiction => jur)
      user.should_not be_valid
    end
  end

	describe "visible groups" do
		before(:each) do
			@owner = FactoryGirl.create(:user)
			@nonowner = FactoryGirl.create(:user)
			@global_nonowner = FactoryGirl.create(:user)
			jurisdiction = FactoryGirl.create(:jurisdiction)
			state = FactoryGirl.create(:jurisdiction)
			jurisdiction.move_to_child_of(state)
			@alerter = FactoryGirl.create(:role, :alerter => true)
			FactoryGirl.create(:role_membership, :role => @alerter, :jurisdiction => jurisdiction, :user => @owner)
			FactoryGirl.create(:role_membership, :role => @alerter, :jurisdiction => jurisdiction, :user => @nonowner)
			FactoryGirl.create(:role_membership, :role => @alerter, :jurisdiction => state, :user => @global_nonowner)
			@g1 = FactoryGirl.create(:group, :owner => @owner, :scope => "Personal", :users => [FactoryGirl.create(:user)])
			@g2 = FactoryGirl.create(:group, :owner => @owner, :scope => "Jurisdiction", :owner_jurisdiction => jurisdiction, :jurisdictions => [FactoryGirl.create(:jurisdiction)])
			@g3 = FactoryGirl.create(:group, :owner => @owner, :scope => "Global", :users => [FactoryGirl.create(:user)])
		end
		it "should return all owned groups" do
			@owner.visible_groups.should include(@g1)
			@owner.visible_groups.should include(@g2)
			@owner.visible_groups.should include(@g3)
		end
		it "should return all jurisdiction-scoped groups for user's jurisdictions" do
			@nonowner.visible_groups.should include(@g2)
		end
		it "should not return any jurisdiction-scoped groups for jurisdictions that user is not a member of" do
			@global_nonowner.visible_groups.should_not include(@g1)
			@global_nonowner.visible_groups.should_not include(@g2)
		end
		it "should return all globally-scoped groups" do
			@global_nonowner.visible_groups.should include(@g3)
		end
	end
end

