class AddOriginalAlertIdToAlerts < ActiveRecord::Migration
  def self.up
    add_column :alerts, :original_alert_id, :integer
  end

  def self.down
    remove_column :alerts, :original_alert_id
  end
end
