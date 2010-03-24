class CreateOrganizationMembershipRequests < ActiveRecord::Migration
  def self.up
    create_table :organization_membership_requests do |t|
      t.integer :organization_id, :null => false
      t.integer :user_id, :null => false
      t.integer :approver_id
    end
  end

  def self.down
    drop_table :organization_membership_requests
  end
end
