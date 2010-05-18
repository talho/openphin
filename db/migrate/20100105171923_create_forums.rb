class CreateForums < ActiveRecord::Migration
  def self.up
    create_table :forums do |t|
      t.string :name
      t.timestamp :hidden_at, :default => nil
      t.timestamps
    end
  end
  
  def self.down
    drop_table :forums
  end
end
