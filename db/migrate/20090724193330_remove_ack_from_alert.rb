class RemoveAckFromAlert < ActiveRecord::Migration
  def self.up
    remove_column :alerts, :alert_acknowledged
    remove_column :alerts, :alert_acknowledged_timestamp
  end

  def self.down
    add_column :alerts, :alert_acknowledged, :boolean
    add_column :alerts, :alert_acknowledged_timestamp, :time
  end
end
