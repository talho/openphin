class AddAlertType < ActiveRecord::Migration
  def up
    unless AlertAttempt.column_names.include?('alert_type')      
      add_column(:alert_attempts, :alert_type, :string)     
    end
    unless AlertAckLog.column_names.include?('alert_type')      
      add_column(:alert_ack_logs, :alert_type, :string)
    end
    unless AlertDeviceType.column_names.include?('alert_type')      
      add_column(:alert_device_types, :alert_type, :string)
    end
    
    execute "update alert_attempts set alert_type = A.alert_type from alerts A inner join alert_attempts AA on A.id = AA.alert_id"
    execute "update alert_ack_logs set alert_type = A.alert_type from alerts A inner join alert_ack_logs AA on A.id = AA.alert_id"
    execute "update alert_device_types set alert_type = A.alert_type from alerts A inner join alert_device_types AA on A.id = AA.alert_id"
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
