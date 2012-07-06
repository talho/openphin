class AddAlertType < ActiveRecord::Migration
  def up

    unless Alert.column_names.include?('alert_type')
      add_column(:alerts, :alert_type, :string)
    end
    unless AlertAttempt.column_names.include?('alert_type')
      add_column(:alert_attempts, :alert_type, :string)
    end
    unless AlertAckLog.column_names.include?('alert_type')
      add_column(:alert_ack_logs, :alert_type, :string)
    end
    unless AlertDeviceType.column_names.include?('alert_type')
      add_column(:alert_device_types, :alert_type, :string)
    end

    execute "UPDATE alerts SET alert_type = 'Alert' WHERE alert_type IS NULL"
    execute "UPDATE alert_attempts SET alert_type = a.alert_type FROM alerts a WHERE a.id = alert_id AND alert_attempts.alert_type IS NULL"
    execute "UPDATE alert_ack_logs SET alert_type = a.alert_type FROM alerts a WHERE a.id = alert_id AND alert_ack_logs.alert_type IS NULL"
    execute "UPDATE alert_device_types SET alert_type = a.alert_type FROM alerts a WHERE a.id = alert_id AND alert_device_types.alert_type IS NULL"
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
