class AddApplicationToRoles < ActiveRecord::Migration
  def self.up
    add_column :roles, :application, :string
    Role.find(:all).each { | r | r.update_attribute(:application, r.name=='Rollcall' ? 'rollcall' : 'phin') }
#    Role.find_by_name("Admin").update_attributes(:name => 'Phin Admin')
#    Role.find_by_name("OrgAdmin").update_attributes(:name => 'Phin OrgAdmin')
#    Role.find_by_name("Superadmin").update_attributes(:name => 'SuperAdmin')
#    Role.find_by_name("Rollcall").update_attributes(:application => 'rollcall', :name => 'Rollcall Admin')
    Role.new(:name => 'SysAdmin', :application => 'system', :user_role => false, :approval_required => true).save!
  end

  def self.down
    Role.find_by_name_and_application('SysAdmin', 'system').destroy
#    Role.find_by_name("Phin Admin").update_attributes(:name => 'Admin')
#    Role.find_by_name("Phin OrgAdmin").update_attributes(:name => 'OrgAdmin')
#    Role.find_by_name("Phin SuperAdmin").update_attributes(:name => 'Superadmin')
#    Role.find_by_name("Rollcall Admin").update_attributes(:name => 'Rollcall')
    remove_column :roles, :application
  end
end
