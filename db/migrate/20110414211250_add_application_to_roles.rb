class AddApplicationToRoles < ActiveRecord::Migration
  class Role < ActiveRecord::Base
    
  end
  
  def self.up
    add_column :roles, :application, :string
    AddApplicationToRoles::Role.find(:all).each { | r | r.update_attribute(:application, r.name=='Rollcall' ? 'rollcall' : 'phin') }
    begin  
      AddApplicationToRoles::Role.find_by_name_and_application('Superadmin', 'phin').update_attributes(:name => 'SuperAdmin')
    rescue
    end
    AddApplicationToRoles::Role.find_or_create_by_name('SysAdmin') do |r|
      r.application = 'system'
      r.user_role = false
      r.approval_required = true
    end
  end

  def self.down
    AddApplicationToRoles::Role.find_by_name_and_application('SysAdmin', 'system').destroy
    begin
      AddApplicationToRoles::Role.find_by_name_and_application('SuperAdmin', 'phin').update_attributes(:name => 'Superadmin')
    rescue
    end
    remove_column :roles, :application
  end
end
