class AddAlertAudienceTables < ActiveRecord::Migration
  def self.up
    create_table "alerts_users", :id => false do |t|
      t.integer :alert_id
      t.integer :user_id
    end
    
    add_index :alerts_users, :alert_id
    add_index :alerts_users, :user_id
    add_index :alerts_users, [:alert_id, :user_id]
    
    create_table "alerts_jurisdictions", :id => false do |t|
      t.integer :alert_id
      t.integer :jurisdiction_id
    end
    
    add_index :alerts_jurisdictions, :alert_id
    add_index :alerts_jurisdictions, :jurisdiction_id
    add_index :alerts_jurisdictions, [:alert_id, :jurisdiction_id]
    
    create_table "alerts_roles", :id => false do |t|
      t.integer :alert_id
      t.integer :role_id
    end
    
    add_index :alerts_roles, :alert_id
    add_index :alerts_roles, :role_id
    add_index :alerts_roles, [:alert_id, :role_id]
    
    create_table "alerts_organizations", :id => false do |t|
      t.integer :alert_id
      t.integer :organization_id
    end
    
    add_index :alerts_organizations, :alert_id
    add_index :alerts_organizations, :organization_id
    add_index :alerts_organizations, [:alert_id, :organization_id]
  end

  def self.down
    drop_table "alerts_users"
    drop_table "alerts_jurisdictions"
    drop_table "alerts_roles"
    drop_table "alerts_organizations"
  end
end
