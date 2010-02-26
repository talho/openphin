
# == Schema Information
#
# Table name: organization_membership_requests
#
#  id              :integer(4)      not null, primary key
#  organization_id :integer(4)      not null
#  user_id         :integer(4)      not null
#  approver_id     :integer(4)
#

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe OrganizationMembershipRequest do
  before(:each) do
    @organization = Factory(:organization)
    @user = Factory(:user)
    @texas = Factory(:jurisdiction, :name => "Texas")
    @valid_attributes = {
      :organization => @organization,
      :user => @user
    }
  end

  it "should create a new instance given valid attributes" do
    OrganizationMembershipRequest.create!(@valid_attributes)
  end

  it "should be approved when approver_id is set and approver superadmin" do
    orm = OrganizationMembershipRequest.create!(@valid_attributes)
    approver = Factory(:user)
    role_membership = Factory(:role_membership, :role => Role.superadmin, :jurisdiction => @texas, :user => approver)
    orm.approve!(approver).should be_true
  end

  it "should not be approved when approver_id is set and approver is not superadmin" do
    orm = OrganizationMembershipRequest.create!(@valid_attributes)
    approver = Factory(:user)
    role_membership = Factory(:role_membership, :role => Role.admin, :jurisdiction => @texas, :user => approver)
    orm.approve!(approver).should be_nil
  end

  it "should not approve when approver_id is already set" do
    orm = OrganizationMembershipRequest.create!(@valid_attributes)
    approver = Factory(:user)
    role_membership = Factory(:role_membership, :role => Role.superadmin, :jurisdiction => @texas, :user => approver)
    orm.approve!(approver).should be_true
    orm.approve!(approver).should be_nil
  end
end