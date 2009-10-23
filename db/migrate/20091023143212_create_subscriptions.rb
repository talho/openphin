class CreateSubscriptions < ActiveRecord::Migration
  def self.up
    create_table :subscriptions do |t|
      t.integer :channel_id
      t.integer :user_id
      t.boolean :owner

      t.timestamps
    end
  end

  def self.down
    drop_table :subscriptions
  end
end
