# == Schema Information
#
# Table name: role_requests
#
#  id              :integer         not null, primary key
#  requester_id    :string(255)
#  role_id         :string(255)
#  approver_id     :string(255)
#  created_at      :datetime
#  updated_at      :datetime
#  jurisdiction_id :integer
#

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe RoleRequest do
  before(:each) do
    @valid_attributes = {
      :requester_id => "value for requester_id",
      :role_id => "value for role_id",
      :approver_id => "value for approver_id"
    }
  end

  it "should create a new instance given valid attributes" do
    RoleRequest.create!(@valid_attributes)
  end
end
