class RenameModelTables < ActiveRecord::Migration
  def self.up
    rename_table :phin_jurisdictions, :jurisdictions
    rename_table :phin_people, :users
    rename_table :phin_roles, :roles
    rename_table :phin_person_profiles, :user_profiles
  end

  def self.down
    rename_table :user_profiles, :phin_person_profiles
    rename_table :roles, :phin_roles
    rename_table :users, :phin_people
    rename_table :jurisdictions, :phin_jurisdictions
  end
end
