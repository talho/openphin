class AddOwnerJurisdictionToGroups < ActiveRecord::Migration
  def self.up
    add_column :groups, :owner_jurisdiction_id, :integer
  end

  def self.down
    remove_column :groups, :owner_jurisdiction_id
  end
end
