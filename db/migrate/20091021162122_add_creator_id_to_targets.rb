class AddCreatorIdToTargets < ActiveRecord::Migration
  def self.up
    add_column :targets, :creator_id, :integer
  end

  def self.down
    remove_column :targets, :creator_id
  end
end
