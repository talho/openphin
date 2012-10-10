class RemoveLockVersionFromAlerts < ActiveRecord::Migration
  def up
    if table_exists? :view_han_alerts
      RemoveMTIFor("HanAlert", {:superclass_name => 'Alert', :supertable_name => 'alerts', :table_name => 'han_alerts'})
    end
    
    if table_exists? :view_vms_alerts
      RemoveMTIFor(VmsStatusCheckAlert, {:superclass_name => 'Alert', :supertable_name => 'alerts', :table_prefix => 'view_status_check_', :table_name => 'vms_alerts'})
      RemoveMTIFor(VmsStatusAlert, {:superclass_name => 'Alert', :supertable_name => 'alerts', :table_prefix => 'view_status_', :table_name => 'vms_alerts'})
      RemoveMTIFor(VmsExecutionAlert, {:superclass_name => 'Alert', :supertable_name => 'alerts', :table_prefix => 'view_execution_', :table_name => 'vms_alerts'})
      RemoveMTIFor(VmsAlert, {:superclass_name => 'Alert', :supertable_name => 'alerts', :table_name => 'vms_alerts'})        
    end
    
    if table_exists? :view_rollcall_alerts
      begin
        RemoveMTIFor(RollcallAlert, {:superclass_name => 'Alert', :supertable_name => 'alerts', :table_name => 'rollcall_alerts'})
      rescue Exception => e
       p e.message
       p e.backtrace
      end      
    end
    
    remove_column :alerts, :lock_version
  end

  def down
    add_column :alerts, :lock_version, :integer, :default => 0
  end
end
