class ChangeOrganizations < ActiveRecord::Migration
  def self.up
    drop_table :organization_requests
    
    create_table :organizations_admins, :id => false do |t|
      t.integer :organization_id
      t.integer :user_id
    end
    
    add_index :organizations_admins, :organization_id
    add_index :organizations_admins, :user_id
    
    change_column :organizations, :description, :text
  end

  def self.down
    create_table "organization_requests", :force => true do |t|
      t.integer  "organization_id"
      t.integer  "jurisdiction_id"
      t.boolean  "approved",        :default => false, :null => false
      t.integer  "approver_id"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.integer  "lock_version",    :default => 0,     :null => false
    end
  
    add_index "organization_requests", ["approver_id"], :name => "index_organization_requests_on_approver_id"
    add_index "organization_requests", ["id"], :name => "index_organization_requests_on_id"
    add_index "organization_requests", ["jurisdiction_id"], :name => "index_organization_requests_on_jurisdiction_id"
    add_index "organization_requests", ["organization_id"], :name => "index_organization_requests_on_organization_id"
  end
end
