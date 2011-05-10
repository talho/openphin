class AddApplicationToRoles < ActiveRecord::Migration
  def self.up
    add_column :roles, :application, :string
    Role.find(:all).each { | r | r.update_attribute(:application, r.name=='Rollcall' ? 'rollcall' : 'phin') }
    Role.find_or_create_by_name_and_application_and_user_role_and_approval_required('SysAdmin', 'system', false, true)
  end

  def self.down
    Role.find_by_name_and_application('SysAdmin', 'system').destroy
    remove_column :roles, :application
  end
end
