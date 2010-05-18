class AddIndexesToTopic < ActiveRecord::Migration
  def self.up
    add_index :topics, :updated_at
    add_index :topics, :sticky
    add_index :topics, :comment_id
  end

  def self.down
    remove_index :topics, :updated_at
    remove_index :topics, :sticky
    remove_index :topics, :comment_id
  end
end
