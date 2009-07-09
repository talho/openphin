class AddPropertiesToRoleMembership < ActiveRecord::Migration
  def self.up
    add_column :role_memberships, :phin_jurisdiction_id, :integer
  end

  def self.down
    remove_column :role_memberships, :phin_jurisdiction_id
  end
end
