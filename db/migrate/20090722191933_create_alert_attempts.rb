class CreateAlertAttempts < ActiveRecord::Migration
  def self.up
    create_table :alert_attempts do |t|
      t.integer :alert_id
      t.integer :user_id
      t.integer :device_id
      t.timestamp :requested_at
      t.timestamp :acknowledged_at

      t.timestamps
    end
  end

  def self.down
    drop_table :alert_attempts
  end
end
