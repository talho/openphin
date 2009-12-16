class AddIndexToJurisdictions < ActiveRecord::Migration
  def self.up
    add_index :jurisdictions, :parent_id
  end

  def self.down
    remove_index :jurisdictions, :parent_id
  end
end
