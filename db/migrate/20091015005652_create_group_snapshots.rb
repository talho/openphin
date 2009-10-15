class CreateGroupSnapshots < ActiveRecord::Migration
  def self.up
    create_table :group_snapshots do |t|
      t.integer :group_id
      t.integer :alert_id

      t.timestamps
    end
    
    create_table :group_snapshots_users, :id => false do |t|
      t.integer :group_snapshot_id
      t.integer :user_id
    end
  end

  def self.down
    drop_table :group_snapshots
    drop_table :group_snapshots_roles
    drop_table :group_snapshots_jurisdictions
    drop_table :group_snapshots_users
  end
end
