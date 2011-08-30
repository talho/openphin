class AddApplicationDefaultToDashboard < ActiveRecord::Migration
  def self.up
    add_column :dashboards, :application_default, :boolean, :default => false
  end

  def self.down
    remove_column :dashboards, :application_default
  end
end
