class AddForumIdToAudiences < ActiveRecord::Migration
  def self.up
    add_column :audiences, :forum_id, :integer
  end

  def self.down
    remove_column :audiences, :forum_id, :integer
  end
end
