class AddSensitiveToAlerts < ActiveRecord::Migration
  def self.up
    add_column :alerts, :sensitive, :boolean
  end

  def self.down
    remove_column :alerts, :sensitive
  end
end
