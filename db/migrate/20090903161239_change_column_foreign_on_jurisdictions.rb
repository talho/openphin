class ChangeColumnForeignOnJurisdictions < ActiveRecord::Migration
  def self.up
    change_column(:jurisdictions, :foreign, :boolean, :default => false, :null => false)
  end

  def self.down
    change_column(:jurisdictions, :foreign, :boolean, :default => nil, :null => true)
  end
end
