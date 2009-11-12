class AddIndexesToDevicesAndRoleMemberships < ActiveRecord::Migration
  def self.up
    add_index :devices, :user_id
    add_index :role_memberships, :user_id
    add_index :role_requests, :user_id
    add_index :jurisdictions, :name
  end

  def self.down
    remove_index :devices, :user_id
    remove_index :role_memberships, :user_id
    remove_index :role_requests, :user_id
    remove_index :jurisdictions, :name
  end
end
