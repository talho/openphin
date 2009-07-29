class AddDeltaToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :delta, :boolean
  end

  def self.down
    remove_column :users, :delta
  end
end
