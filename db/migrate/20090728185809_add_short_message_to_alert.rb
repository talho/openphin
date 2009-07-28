class AddShortMessageToAlert < ActiveRecord::Migration
  def self.up
    add_column :alerts, :short_message, :string
  end

  def self.down
    remove_column :alerts, :short_message
  end
end
