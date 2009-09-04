class AddCallerIdToAlerts < ActiveRecord::Migration
  def self.up
    add_column :alerts, :caller_id, :string
  end

  def self.down
    remove_column :alerts, :caller_id
  end
end
