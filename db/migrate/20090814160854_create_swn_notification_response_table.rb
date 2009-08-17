class CreateSwnNotificationResponseTable < ActiveRecord::Migration
  def self.up
    create_table :swn_notification_response do |t|
      t.integer :alert_id
      t.integer :message_id
    end
  end

  def self.down
    drop_table :swn_notificiation_response
  end
end
