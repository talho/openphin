class AddDeltaToDocuments < ActiveRecord::Migration
  def self.up
    add_column :documents, :delta, :boolean, :default => 1
  end

  def self.down
    remove_column :documents, :delta
  end
end
