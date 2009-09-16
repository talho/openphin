# == Schema Information
#
# Table name: organization_memberships
#
#  id                      :integer(4)      not null, primary key
#  organization_id         :integer(4)
#  jurisdiction_id         :integer(4)
#  organization_request_id :integer(4)
#  created_at              :datetime
#  updated_at              :datetime
#

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe OrganizationMembership do
  before(:each) do
    jurisdiction = Factory(:jurisdiction)
    organization = Factory(:organization)
    @valid_attributes = {
      :jurisdiction => jurisdiction,
      :organization => organization,
      :organization_request => OrganizationRequest.create(:jurisdiction => jurisdiction, :organization => organization)
    }
  end

  it "should create a new instance given valid attributes" do
    OrganizationMembership.create!(@valid_attributes)
  end
end
