class AddRequesterIdToOrganizationMembershipRequests < ActiveRecord::Migration
  def self.up
    add_column :organization_membership_requests, :requester_id, :integer
  end

  def self.down
    remove_column :organization_membership_requests, :requester_id
  end
end
