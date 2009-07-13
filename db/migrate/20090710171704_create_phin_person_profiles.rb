class CreatePhinPersonProfiles < ActiveRecord::Migration
  def self.up
    create_table :phin_person_profiles do |t|
      t.binary :photo
      t.boolean :public
      t.text :credentials
      t.string :employer
      t.text :experience
      t.text :bio
      t.integer :phin_person_id 

      t.timestamps
    end
  end

  def self.down
    drop_table :phin_person_profiles
  end
end
