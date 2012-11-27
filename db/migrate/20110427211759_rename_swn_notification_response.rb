class RenameSwnNotificationResponse < ActiveRecord::Migration
  def self.up
    rename_table "swn_notification_response", "message_notification_response"
    rename_column "message_notification_response", :message_id, :response_id
    add_column "message_notification_response", :message_id, :string
    execute "UPDATE message_notification_response SET message_id=view_han_alerts.distribution_id FROM view_han_alerts WHERE view_han_alerts.id=message_notification_response.alert_id" if ActiveRecord::Base.connection.table_exists? 'view_han_alerts'
    remove_column "message_notification_response", :alert_id
    add_column "message_notification_response", :response, :text
  end

  def self.down
    remove_column "message_notification_response", :response
    add_column "message_notification_response", :alert_id, :integer
    execute "UPDATE message_notification_response SET alert_id=view_han_alerts.id FROM view_han_alerts WHERE view_han_alerts.distribution_id=message_notification_response.message_id" if ActiveRecord::Base.connection.table_exists? 'view_han_alerts'
    remove_column "message_notification_response", :message_id
    rename_column "message_notification_response", :response_id, :message_id
    rename_table "message_notification_response", "swn_notification_response"
  end
end
