class AddFipsCodeToJurisdictions < ActiveRecord::Migration
  def self.up
    add_column :jurisdictions, :fips_code, :string
    add_index :jurisdictions, :fips_code
  end

  def self.down
    remove_column :jurisdictions, :fips_code
  end
end
