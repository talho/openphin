# == Schema Information
#
# Table name: role_memberships
#
#  id              :integer         not null, primary key
#  role_id         :integer
#  user_id         :integer
#  created_at      :datetime
#  updated_at      :datetime
#  jurisdiction_id :integer
#  role_request_id :integer
#

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe RoleMembership do
  before(:each) do
    @valid_attributes = {
    }
  end

  it "should create a new instance given valid attributes" do
    RoleMembership.create!(@valid_attributes)
  end
  
  it "should be unique for role, jurisdiction, and user" do
    membership = Factory(:role_membership)
    bad_membership = Factory.build(:role_membership, 
      :user => membership.user, 
      :jurisdiction => membership.jurisdiction, 
      :role => membership.role)
    bad_membership.should_not be_valid
  end
end
