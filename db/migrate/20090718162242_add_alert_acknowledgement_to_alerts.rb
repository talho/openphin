class AddAlertAcknowledgementToAlerts < ActiveRecord::Migration
  def self.up
    add_column :alerts, :alert_acknowledged, :boolean
    add_column :alerts, :alert_acknowledged_timestamp, :datetime
  end

  def self.down
    remove_column :alerts, :alert_acknowledged_timestamp
    remove_column :alerts, :alert_acknowledged
  end
end
