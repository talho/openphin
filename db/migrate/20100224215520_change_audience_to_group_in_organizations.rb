class ChangeAudienceToGroupInOrganizations < ActiveRecord::Migration
  def self.up
    rename_column :organizations, :audience_id, :group_id
  end

  def self.down
    rename_column :organizations, :group_id, :audience_id
  end
end
