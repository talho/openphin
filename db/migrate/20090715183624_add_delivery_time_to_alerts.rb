class AddDeliveryTimeToAlerts < ActiveRecord::Migration
  def self.up
    add_column :alerts, :delivery_time, :integer
  end

  def self.down
    remove_column :alerts, :delivery_time
  end
end
