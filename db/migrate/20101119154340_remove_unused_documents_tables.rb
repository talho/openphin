class RemoveUnusedDocumentsTables < ActiveRecord::Migration
  def self.up
    drop_table :documents_shares
    drop_table :opt_out_shares_users
    drop_table :shares
    drop_table :subscriptions
    drop_table :permissions
  end

  def self.down
    create_table "shares", :force => true do |t|
      t.string   "name"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.integer  "lock_version", :default => 0, :null => false
      t.integer  "audience_id"
      t.integer  "user_id",                     :null => false
    end

    add_index "shares", ["audience_id"], :name => "index_shares_on_audience_id"
    add_index "shares", ["id"], :name => "index_channels_on_id"
    add_index "shares", ["user_id"], :name => "index_shares_on_user_id"

    create_table "subscriptions", :force => true do |t|
      t.integer  "share_id"
      t.integer  "user_id"
      t.boolean  "owner"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.integer  "lock_version", :default => 0, :null => false
    end

    create_table "permissions", :force => true do |t|
      t.integer "user_id",    :null => false
      t.integer "share_id",   :null => false
      t.integer "permission", :null => false
    end

    add_index "subscriptions", ["id"], :name => "index_subscriptions_on_id"
    add_index "subscriptions", ["share_id"], :name => "index_subscriptions_on_share_id"
    add_index "subscriptions", ["user_id"], :name => "index_subscriptions_on_user_id"

    create_table "documents_shares", :id => false, :force => true do |t|
      t.integer "document_id"
      t.integer "share_id"
      t.integer "lock_version", :default => 0, :null => false
    end

    add_index "documents_shares", ["document_id", "share_id"], :name => "index_channels_documents_on_document_id_and_channel_id"
    add_index "documents_shares", ["document_id"], :name => "index_channels_documents_on_document_id"
    add_index "documents_shares", ["share_id"], :name => "index_channels_documents_on_channel_id"

    create_table "opt_out_shares_users", :id => false, :force => true do |t|
      t.integer "user_id",  :null => false
      t.integer "share_id", :null => false
    end
  end
end
