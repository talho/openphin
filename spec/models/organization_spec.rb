require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Organization do

  describe "validations" do

    before(:each) do
      @jurisdiction = Factory(:jurisdiction)
      Factory(:jurisdiction).move_to_child_of(@jurisdiction)
      @organization = Factory.build(:organization)
    end

    it "should not be valid without a name" do
      @organization.name = ""
      @organization.valid?.should be_false
    end

    it "should not be valid without a description" do
      @organization.description = ""
      @organization.valid?.should be_false
    end

    it "should not be valid without a distribution_email" do
      @organization.distribution_email = ""
      @organization.valid?.should be_false
    end

    it "should not be valid without a city (locality)" do
      @organization.locality = ""
      @organization.valid?.should be_false
    end

    it "should not be valid without a state" do
      @organization.state = ""
      @organization.valid?.should be_false
    end

    it "should not be valid without a postal_code" do
      @organization.postal_code = ""
      @organization.valid?.should be_false
    end

    it "should not be valid without a phone" do
      @organization.phone = ""
      @organization.valid?.should be_false
    end

    it "should not be valid without a contact display name" do
      @organization.contact_display_name = ""
      @organization.valid?.should be_false
    end

    it "should not be valid without a contact email" do
      @organization.contact_email = ""
      @organization.valid?.should be_false
    end

    it "should not be valid without a contact phone" do
      @organization.contact_phone = ""
      @organization.valid?.should be_false
    end

  end

  describe "default scope" do
    before do
      @jurisdiction = Factory(:jurisdiction)
      Factory(:jurisdiction).move_to_child_of(@jurisdiction)
      Organization.delete_all
      Organization.create! :name => 'Banana', :distribution_email => "abc@email.com", :postal_code => "22212", :phone => "555-555-5555", :street => "123 Willow Ave. Suite 34", :locality => "Dallas", :state => "TX", :description => "National Organization", :contact_display_name => "Bob Barker", :contact_email => "@bob@barker.com", :contact_phone => "555-555-5555"
      Organization.create! :name => 'Apple', :distribution_email => "abc@email.com", :postal_code => "22212", :phone => "555-555-5555", :street => "123 Willow Ave. Suite 34", :locality => "Dallas", :state => "TX", :description => "National Organization", :contact_display_name => "Bob Barker", :contact_email => "@bob@barker.com", :contact_phone => "555-555-5555"
      Organization.create! :name => 'Cucumber', :distribution_email => "abc@email.com", :postal_code => "22212", :phone => "555-555-5555", :street => "123 Willow Ave. Suite 34", :locality => "Dallas", :state => "TX", :description => "National Organization", :contact_display_name => "Bob Barker", :contact_email => "@bob@barker.com", :contact_phone => "555-555-5555"
    end
    
    it 'should sort by name' do
      Organization.all.map(&:name).should == %w(Apple Banana Cucumber)
    end
  end
  
  describe "parent/child relationships" do
    it "should return an array of people from .users" do
      @jurisdiction = Factory(:jurisdiction)
      Factory(:jurisdiction).move_to_child_of(@jurisdiction)
      o=Factory(:organization, :name => "APHC")
      p=Factory(:user)
      o.users << p
      o.users.length.should == 1
    end  
  end
  
  describe "finders" do
    describe ".approved" do
      it "should return only approved organizations " do
        unapproved_org = Factory(:organization, :approved => false)
        organization1 = Factory(:organization)
        OrganizationRequest.create!(:approved => true, :jurisdiction => Factory(:jurisdiction), :organization => organization1)
        organization2 = Factory(:organization)
        OrganizationRequest.create!(:approved => true, :jurisdiction => Factory(:jurisdiction), :organization => organization2)
        approved_orgs = [organization1, organization2]
        Organization.approved.should include(*approved_orgs)
        Organization.approved.should_not include(unapproved_org)
      end
    end
  end
end

# == Schema Information
#
# Table name: organizations
#
#  id                        :integer(4)      not null, primary key
#  name                      :string(255)
#  phin_oid                  :string(255)
#  description               :string(255)
#  fax                       :string(255)
#  locality                  :string(255)
#  postal_code               :string(255)
#  state                     :string(255)
#  street                    :string(255)
#  phone                     :string(255)
#  alerting_jurisdictions    :string(255)
#  primary_organization_type :string(255)
#  type                      :string(255)
#  created_at                :datetime
#  updated_at                :datetime
#  foreign                   :boolean(1)
#  queue                     :string(255)
#  distribution_email        :string(255)
#  approved                  :boolean(1)      default(FALSE)
#  token                     :string(128)
#  email_confirmed           :boolean(1)      default(FALSE), not null
#  user_id                   :integer(4)
#  group_id                  :integer(4)
#

