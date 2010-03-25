class AddCrossJurisdictionToAlert < ActiveRecord::Migration
  def self.up
    add_column :alerts, :cross_jurisdiction, :boolean, :default => true
  end

  def self.down
    remove_column :alerts, :cross_jurisdiction
  end
end
