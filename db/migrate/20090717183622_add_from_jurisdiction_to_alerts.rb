class AddFromJurisdictionToAlerts < ActiveRecord::Migration
  def self.up
    add_column :alerts, :from_jurisdiction_id, :integer
  end

  def self.down
    remove_column :alerts, :from_jurisdiction_id
  end
end
