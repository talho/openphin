class RemoveLockVersionFromAudienceLinkTables < ActiveRecord::Migration
  def self.up
    remove_column :audiences_jurisdictions, :lock_version
    remove_column :audiences_roles, :lock_version
    remove_column :audiences_users, :lock_version
    remove_column :jurisdictions_organizations, :lock_version
    remove_column :targets_users, :lock_version
  end

  def self.down
    add_column :audiences_jurisdictions, "lock_version", :integer, :default => 0, :null => false
    add_column :audiences_roles, "lock_version", :integer, :default => 0, :null => false
    add_column :audiences_users, "lock_version", :integer, :default => 0, :null => false
    add_column :jurisdictions_organizations, "lock_version", :integer, :default => 0, :null => false
    add_column :targets_users, "lock_version", :integer, :default => 0, :null => false
  end
end
