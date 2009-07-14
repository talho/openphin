class AddOptionsToDevices < ActiveRecord::Migration
  def self.up
    add_column :devices, :options, :text
  end

  def self.down
    remove_column :devices, :options
  end
end
