class AddColumnsToFolders < ActiveRecord::Migration
  def self.up
    change_table :folders do |t|
      t.integer :audience_id
      t.index :audience_id
      t.boolean :notify_of_audience_addition
      t.boolean :notify_of_document_addition
      t.boolean :notify_of_file_download
      t.boolean :expire_documents, :default => true
      t.boolean :notify_before_document_expiry, :default => true
    end
  end

  def self.down
    change_table :folders do |t|
      t.remove_index :audience_id
      t.remove :audience_id
      t.remove :notify_of_audience_addition
      t.remove :notify_of_document_addition
      t.remove :notify_of_file_download
      t.remove :expire_documents, :default => true
      t.remove :notify_before_document_expiry, :default => true
    end
  end
end
