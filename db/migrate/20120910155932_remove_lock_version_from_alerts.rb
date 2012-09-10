class RemoveLockVersionFromAlerts < ActiveRecord::Migration
  def up
    Phin::Application.eval_if_plugin_present :han do
      RemoveMTIFor(HanAlert, {:superclass_name => 'Alert', :supertable_name => 'alerts', :table_name => 'han_alerts'})
    end
    
    Phin::Application.eval_if_plugin_present :vms do
      RemoveMTIFor(VmsStatusCheckAlert, {:superclass_name => 'Alert', :supertable_name => 'alerts', :table_prefix => 'view_status_check_', :table_name => 'vms_alerts'})
      RemoveMTIFor(VmsStatusAlert, {:superclass_name => 'Alert', :supertable_name => 'alerts', :table_prefix => 'view_status_', :table_name => 'vms_alerts'})
      RemoveMTIFor(VmsExecutionAlert, {:superclass_name => 'Alert', :supertable_name => 'alerts', :table_prefix => 'view_execution_', :table_name => 'vms_alerts'})
      RemoveMTIFor(VmsAlert, {:superclass_name => 'Alert', :supertable_name => 'alerts', :table_name => 'vms_alerts'})        
    end
    
    Phin::Application.eval_if_plugin_present :rollcall do
      RemoveMTIFor(RollcallAlert, {:superclass_name => 'Alert', :supertable_name => 'alerts', :table_name => 'rollcall_alerts'})      
    end
    
    remove_column :alerts, :lock_version
  end

  def down
    add_column :alerts, :lock_version, :integer, :default => 0
  end
end
