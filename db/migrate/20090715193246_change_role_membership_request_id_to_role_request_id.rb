class ChangeRoleMembershipRequestIdToRoleRequestId < ActiveRecord::Migration
  def self.up
    rename_column :role_memberships, :request_id, :role_request_id
  end

  def self.down
    rename_column :role_memberships, :role_request_id, :request_id
  end
end
