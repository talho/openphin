class DefaultForeignToFalseInOrganizations < ActiveRecord::Migration
  def self.up
    change_column :organizations, :foreign, :boolean, :default => false, :null => false
  end

  def self.down
    change_column :organizations, :foreign, :boolean, :default => nil, :null => true
  end
end
