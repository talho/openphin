class CreateArticles < ActiveRecord::Migration
  def self.up
    create_table :articles do |t|
      t.integer :author_id
      t.integer :pub_date
      t.string :title
      t.text :lede
      t.text :body
      t.boolean :visible

      t.timestamps
    end
  end

  def self.down
    drop_table :articles
  end
end
