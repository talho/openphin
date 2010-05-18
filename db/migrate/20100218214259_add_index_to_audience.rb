class AddIndexToAudience < ActiveRecord::Migration
  def self.up
    add_index :audiences, :forum_id
  end

  def self.down
    remove_index :audiences, :forum_id
  end
end
