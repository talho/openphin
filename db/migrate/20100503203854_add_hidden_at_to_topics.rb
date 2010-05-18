class AddHiddenAtToTopics < ActiveRecord::Migration
  def self.up
    add_column :topics, :hidden_at, :timestamp, :default => nil
  end

  def self.down
    remove_column :topics, :hiddent_at
  end
end
