class AddCrossJurisdictionToAlert < ActiveRecord::Migration
  def self.up
    add_column :alerts, :not_cross_jurisdictional, :boolean, :default => false
  end

  def self.down
    remove_column :alerts, :not_cross_jurisdictional
  end
end
