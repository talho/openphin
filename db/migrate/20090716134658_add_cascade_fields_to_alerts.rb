class AddCascadeFieldsToAlerts < ActiveRecord::Migration
  def self.up
    add_column :alerts, :sent_at, :datetime
    add_column :alerts, :message_type, :string
    add_column :alerts, :program_type, :string
    add_column :users, :phone, :string
  end

  def self.down
    remove_column :alerts, :sent_at
    remove_column :alerts, :message_type
    remove_column :alerts, :program_type
    remove_column :users, :phone
  end
end
