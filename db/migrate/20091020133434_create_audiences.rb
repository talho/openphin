class CreateAudiences < ActiveRecord::Migration
  def self.up
    rename_table :groups, :audiences
    [:jurisdictions, :roles, :users].each do |table|
      rename_table "groups_#{table}", "audiences_#{table}"
      rename_column "audiences_#{table}", :group_id, :audience_id
    end
    rename_column :group_snapshots, :group_id, :audience_id
    add_column :audiences, :type, :string
  end

  def self.down
    remove_column :audiences, :type
    rename_column :group_snapshots, :audience_id, :group_id
    [:jurisdictions, :roles, :users].each do |table|
      rename_column "audiences_#{table}", :audience_id, :group_id
      rename_table "audiences_#{table}", "groups_#{table}"
    end
    rename_table :audiences, :groups
  end
end
