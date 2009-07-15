class AddRoleRequestAssociationToRoleMembership < ActiveRecord::Migration
  def self.up
    add_column :role_memberships, :request_id, :integer
  end

  def self.down
    remove_column :role_memberships, :request_id
  end
end
