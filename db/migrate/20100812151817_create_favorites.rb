class CreateFavorites < ActiveRecord::Migration
  def self.up
    create_table :favorites do |t|
      t.string :tab_config
      t.integer :user_id

      t.timestamps
    end

    add_index :favorites, :user_id
  end

  def self.down
    drop_table :favorites
  end
end
