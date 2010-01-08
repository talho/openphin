class AddIndexesToJurisdictions < ActiveRecord::Migration
  def self.up
    add_index :jurisdictions, :lft
    add_index :jurisdictions, :rgt

  end

  def self.down
    remove_index :jurisdictions, :lft
    remove_index :jurisdictions, :rgt
    
  end
end
