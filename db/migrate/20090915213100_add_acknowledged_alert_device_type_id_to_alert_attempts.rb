class AddAcknowledgedAlertDeviceTypeIdToAlertAttempts < ActiveRecord::Migration
  def self.up
    add_column :alert_attempts, :acknowledged_alert_device_type_id, :integer
  end

  def self.down
    remove_column :alert_attempts, :acknowledged_alert_device_type_id
  end
end
