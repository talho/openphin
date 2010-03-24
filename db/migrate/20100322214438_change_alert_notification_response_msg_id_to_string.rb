class ChangeAlertNotificationResponseMsgIdToString < ActiveRecord::Migration
  def self.up
    change_column :swn_notification_response, :message_id, :string
  end

  def self.down
    change_column :swn_notification_response, :message_id, :integer
  end
end
