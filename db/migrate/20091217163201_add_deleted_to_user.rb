class AddDeletedToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :deleted_at, :datetime, :default => nil
    add_column :users, :deleted_by, :string, :default => nil
    add_column :users, :deleted_from, :string, :default => nil, :limit => 24 # support ip addr 6    
  end

  def self.down
    remove_column :users, :deleted_at
    remove_column :users, :deleted_by
    remove_column :users, :deleted_from
  end
end
