class CreateTopics < ActiveRecord::Migration
  def self.up
    create_table :topics do |t|
      t.integer :forum_id
      t.integer :comment_id
      t.integer :sticky, :default => 0
      t.timestamp :locked_at, :default => nil
      t.string :name
      t.text :content
      t.integer :poster_id

      t.timestamps
    end
  end

  def self.down
    drop_table :topics
  end
end
