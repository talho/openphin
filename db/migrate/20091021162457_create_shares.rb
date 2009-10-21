class CreateShares < ActiveRecord::Migration
  def self.up
    create_table :shares do |t|
      t.integer :document_id
      t.integer :user_id
      t.integer :folder_id

      t.timestamps
    end
  end

  def self.down
    drop_table :shares
  end
end
