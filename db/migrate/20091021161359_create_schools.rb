class CreateSchools < ActiveRecord::Migration
  def self.up
    create_table :schools do |t|
      t.string :name
      t.string :display_name
      t.string :level
      t.string :address
      t.string :postal_code
      t.integer :school_number
      t.integer :district_id
      t.timestamps
    end
  end

  def self.down
    drop_table :schools
  end
end
