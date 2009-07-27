class AddAttachmentsPhotoToUserProfile < ActiveRecord::Migration
  def self.up
    add_column :user_profiles, :photo_file_name, :string
    add_column :user_profiles, :photo_content_type, :string
    add_column :user_profiles, :photo_file_size, :integer
    add_column :user_profiles, :photo_updated_at, :datetime
    remove_column :user_profiles, :photo
  end

  def self.down
    add_column :user_profiles, :photo, :binary
    remove_column :user_profiles, :photo_file_name
    remove_column :user_profiles, :photo_content_type
    remove_column :user_profiles, :photo_file_size
    remove_column :user_profiles, :photo_updated_at
  end
end
