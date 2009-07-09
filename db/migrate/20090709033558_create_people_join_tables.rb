class CreatePeopleJoinTables < ActiveRecord::Migration
  def self.up
    create_table :phin_organizations_phin_people do |t|
      t.integer :phin_person_id
      t.integer :phin_organization_id
    end
    create_table :phin_jurisdictions_phin_people do |t|
      t.integer :phin_person_id
      t.integer :phin_jurisdiction_id
    end
  end

  def self.down
    drop_table :phin_organizations_phin_people
    drop_table :phin_jurisdictions_phin_people 
  end
end
