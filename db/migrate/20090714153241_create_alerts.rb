class CreateAlerts < ActiveRecord::Migration
  def self.up
    create_table :alerts do |t|
      t.string :title
      t.text :message
      t.string :severety
      t.string :status
      t.boolean :acknowledge
      t.integer :author_id
      t.timestamps
    end
  end

  def self.down
    drop_table :alerts
  end
end
