class RenameForeignKeys < ActiveRecord::Migration
  def self.up
    rename_column :devices, :phin_person_id, :user_id
    drop_table :phin_jurisdictions_phin_people
    rename_table :phin_organizations_phin_people, :organizations_users
    change_table :organizations_users do |t|
      t.rename :phin_organization_id, :organization_id
      t.rename :phin_person_id, :user_id
    end

    rename_column :user_profiles, :phin_person_id, :user_id
    change_table :role_memberships do |t|
      t.rename :phin_role_id, :role_id
      t.rename :phin_person_id, :user_id
      t.rename :phin_jurisdiction_id, :jurisdiction_id

    end
    rename_column :role_requests, :phin_jurisdiction_id, :jurisdiction_id
  end

  def self.down
    rename_column :devices, :user_id, :phin_person_id
    create_table "phin_jurisdictions_phin_people", :force => true do |t|
      t.integer  "phin_person_id"
      t.integer  "phin_jurisdiction_id"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    change_table :organizations_users do |t|
      t.rename :organization_id, :phin_organization_id
      t.rename :user_id, :phin_person_id
    end
    rename_table :organizations_users, :phin_organizations_phin_people

    rename_column :phin_profiles, :user_id, :phin_person_id
    change_table :role_memberships do |t|
      t.rename :role_id , :phin_role_id
      t.rename :user_id , :phin_person_id
      t.rename :jurisdiction_id, :phin_jurisdiction_id

    end
    rename_column :role_requests, :jurisdiction_id, :phin_jurisdiction_id 
  end
end
