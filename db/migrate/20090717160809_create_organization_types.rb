class CreateOrganizationTypes < ActiveRecord::Migration
  def self.up
    create_table :organization_types do |t|
      t.string :name
      t.timestamps
    end
    
    change_table :organizations do |t|
      t.integer :organization_type_id
    end
    
    add_index :organization_types, :name
  end

  def self.down
    drop_table :organization_types
  end
end
