class CreatePersonRoleJoinTable < ActiveRecord::Migration
  def self.up
    create_table :phin_people_phin_roles, :id => false do |t|
      t.integer :phin_role_id
      t.integer :phin_person_id
      t.timestamps
    end
  end

  def self.down
    drop_table :phin_people_phin_roles
  end
end
