class RenamePersonRoleJoinTable < ActiveRecord::Migration
  def self.up
    rename_table :phin_people_phin_roles, :role_memberships
  end

  def self.down
    rename_table :role_memberships, :phin_people_phin_roles
  end
end
