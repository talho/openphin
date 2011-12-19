class RemoveForumIdFromAudienceAndAddAudienceIdToForum < ActiveRecord::Migration
  def self.up
    add_column :forums, :audience_id, :integer
    execute "
      UPDATE forums
      SET audience_id = audiences.id
      FROM audiences
      WHERE forums.id = audiences.forum_id
    "
    add_index :forums, :audience_id
    remove_index :audiences, :forum_id
    remove_column :audiences, :forum_id
  end

  def self.down
    add_column :audiences, :forum_id, :integer
    execute "
      UPDATE audiences
      SET forum_id = forums.id 
      FROM forums
      WHERE forums.audience_id = audiences.id
    "
    add_index :audiences, :forum_id
    remove_index :forums, :audience_id
    remove_column :forums, :audience_id
  end
end
