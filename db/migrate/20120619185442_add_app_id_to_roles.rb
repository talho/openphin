class AddAppIdToRoles < ActiveRecord::Migration
  class App < ActiveRecord::Base
    
  end
  
  def up
    change_table :roles do |t|
      t.integer :app_id
      t.boolean :public, default: false
    end
    
    apps = execute("SELECT DISTINCT application FROM roles").column_values(0)
    apps.each do |app|
      App.find_or_create_by_name(app)
    end
    
    execute("UPDATE roles SET app_id = apps.id
             FROM apps
             WHERE roles.application = apps.name")
             
    add_index :roles, :app_id
    
    remove_column :roles, :application
  end
  
  def down
    change_table :roles do |t|
      t.string :application
    end
    
    execute("UPDATE roles SET application = apps.name
             FROM apps
             WHERE roles.app_id = apps.id")
    
    remove_index :roles, :app_id
    remove_column :roles, :app_id
    remove_column :roles, :public
  end
end
