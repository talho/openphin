class LinkChannelsToDocuments < ActiveRecord::Migration
  def self.up
    create_table :channels_documents, :id => false do |t|
      t.integer :document_id
      t.integer :channel_id
    end
    
    add_index :channels_documents, :document_id
    add_index :channels_documents, :channel_id
    add_index :channels_documents, [:document_id, :channel_id]
  end

  def self.down
    drop_table :channels_documents
  end
end
