class CreateSchoolDistricts < ActiveRecord::Migration
  def self.up
    create_table :school_districts do |t|
      t.string :name
      t.integer :jurisdiction_id
      t.timestamps
    end
  end

  def self.down
    drop_table :school_districts
  end
end
