class CreateDevices < ActiveRecord::Migration
  def self.up
    create_table :devices do |t|
      t.integer(:phin_person_id)
      t.string(:type)
      t.string :description
      t.string :name
      t.string :coverage
      t.boolean :emergency_use
      t.boolean :home_use
      
    end
  end

  def self.down
  end
end
