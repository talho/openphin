class RefactorDocuments < ActiveRecord::Migration
  def self.up
    add_column "documents", "user_id", :integer
    add_column "documents", "folder_id", :integer
    add_index :documents, :user_id
    add_index :documents, :folder_id
    
    drop_table "shares"
  end

  def self.down
    remove_column "documents", "user_id"
    remove_column "documents", "folder_id"
    
    create_table "shares", :force => true do |t|
      t.integer  "document_id"
      t.integer  "user_id"
      t.integer  "folder_id"
      t.datetime "created_at"
      t.datetime "updated_at"
    end
  end
end
