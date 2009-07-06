class CreatePhinPeople < ActiveRecord::Migration
  def self.up
    create_table :phin_people do |t|

      t.timestamps
    end
  end

  def self.down
    drop_table :phin_people
  end
end
