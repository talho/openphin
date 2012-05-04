# == Schema Information
#
# Table name: role_memberships
#
#  id              :integer(4)      not null, primary key
#  role_id         :integer(4)
#  user_id         :integer(4)
#  created_at      :datetime
#  updated_at      :datetime
#  jurisdiction_id :integer(4)
#  role_request_id :integer(4)
#

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe RoleMembership do
  before(:each) do
    @valid_attributes = {
      :jurisdiction_id => 6,
      :user_id => 7
    }
  end
  
  it { should validate_presence_of(:jurisdiction_id) }
  it { should validate_presence_of(:user_id) }
  
  it "should create a new instance given valid attributes" do
    RoleMembership.create!(@valid_attributes)
  end
  
  it "should be unique for role, jurisdiction, and user" do
    jurisdiction = FactoryGirl.create(:jurisdiction)
    FactoryGirl.create(:jurisdiction).move_to_child_of(jurisdiction)
    user = FactoryGirl.create(:user)
    membership = FactoryGirl.create(:role_membership, :user => user, :jurisdiction => jurisdiction)
    bad_membership = Factory.build(:role_membership, 
      :user => membership.user, 
      :jurisdiction => membership.jurisdiction, 
      :role => membership.role)
    bad_membership.should_not be_valid
  end
end
