class AddCallDownResponsesToAlertAndAlertAttempts < ActiveRecord::Migration
  def self.up
    add_column :alerts, :call_down_messages, :text
    add_column :alert_attempts, :call_down_response, :integer
  end

  def self.down
    remove_column :alerts, :call_down_messages
    remove_column :alert_attempts, :call_down_respones
  end
end
