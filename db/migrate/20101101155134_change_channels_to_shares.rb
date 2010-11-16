class ChangeChannelsToShares < ActiveRecord::Migration
  def self.up
    rename_table(:channels, :shares)
    add_column(:shares, :audience_id, :integer)
    add_index(:shares, :audience_id)
  end

  def self.down
    remove_index(:shares, :audience_id)
    remove_column(:shares, :audience_id)
    rename_table(:shares, :channels)
  end
end
