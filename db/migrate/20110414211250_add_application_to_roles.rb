class AddApplicationToRoles < ActiveRecord::Migration
  def self.up
    add_column :roles, :application, :string
    Role.find(:all).each { | r | 
      r.application = r.name=='Rollcall' ? 'rollcall' : 'phin' 
      r.name = 'Admin' if r.name=='Rollcall'
    }
    Role.new(:name => 'Admin', :application => 'system', :user_role => false, :approval_required => true).save!
    Role.new(:name => 'SuperAdmin', :application => 'system', :user_role => false, :approval_required => true).save!
  end

  def self.down
    remove_column :roles, :application
    Role.find(:name => 'Admin', :application => 'system').destroy!
    Role.find(:name => 'SuperAdmin', :application => 'system').destroy!
  end
end
