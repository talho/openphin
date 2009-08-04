class AddMessageRecordingToAlerts < ActiveRecord::Migration
  def self.up
    add_column :alerts, :message_recording_file_name, :string
    add_column :alerts, :message_recording_content_type, :string
    add_column :alerts, :message_recording_file_size, :integer
  end

  def self.down
    remove_column :alerts, :message_recording_file_name
    remove_column :alerts, :message_recording_content_type
    remove_column :alerts, :message_recording_file_size
  end
end
