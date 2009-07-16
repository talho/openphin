class CreateDeliveries < ActiveRecord::Migration
  def self.up
    create_table :deliveries do |t|
      t.integer :alert_id
      t.integer :device_id
      t.integer :user_id
      t.datetime :delivered_at
      t.datetime :acknowledged_at

      t.timestamps
    end
  end

  def self.down
    drop_table :deliveries
  end
end
