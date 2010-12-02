class CreateFolderPermissionsTable < ActiveRecord::Migration
  def self.up
    create_table :folder_permissions do |t|
      t.integer :folder_id
      t.index :folder_id
      t.integer :user_id
      t.index :user_id
      t.integer :permission
    end
  end

  def self.down
    drop_table :folder_permissions
  end
end
