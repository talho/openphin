class RenameChannelIdColumnsShareId < ActiveRecord::Migration
  def self.up
    remove_index(:subscriptions, 'channel_id')
    rename_column(:subscriptions, :channel_id, :share_id)
    add_index(:subscriptions, :share_id)
  end

  def self.down
    remove_index(:subscriptions, 'share_id')
    rename_column(:subscriptions, :share_id, :channel_id)
    add_index(:subscriptions, :channel_id)
  end
end
