class RenameJurisdictionalLevelColumn < ActiveRecord::Migration
  def self.up
    rename_column :alerts, :jurisdictional_level, :jurisdiction_level
  end

  def self.down
    rename_column :alerts, :jurisdiction_level, :jurisdictional_level
  end
end
