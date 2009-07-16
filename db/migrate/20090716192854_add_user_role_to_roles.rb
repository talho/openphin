class AddUserRoleToRoles < ActiveRecord::Migration
  def self.up
    add_column :roles, :user_role, :boolean, :default => true
  end

  def self.down
    remove_column :roles, :user_role
  end
end
