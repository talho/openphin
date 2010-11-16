class ChangeChannelsDocumentsToSharesDocuments < ActiveRecord::Migration
  def self.up
    rename_table(:channels_documents, :documents_shares)
    rename_column(:documents_shares, :channel_id, :share_id)
  end

  def self.down
    rename_column(:documents_shares, :share_id, :channel_id)
    rename_table(:documents_shares, :channels_documents)
  end
end
