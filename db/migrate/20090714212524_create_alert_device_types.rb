class CreateAlertDeviceTypes < ActiveRecord::Migration
  def self.up
    create_table :alert_device_types do |t|
      t.integer :alert_id
      t.string :device

      t.timestamps
    end
  end

  def self.down
    drop_table :alert_device_types
  end
end
