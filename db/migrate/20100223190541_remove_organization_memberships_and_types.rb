class RemoveOrganizationMembershipsAndTypes < ActiveRecord::Migration
  def self.up
    
    remove_index :organization_types, :name
    remove_index :organizations, :organization_type_id
    
    change_table :organizations do |t|
      t.remove :organization_type_id
    end

    drop_table :organization_memberships
    drop_table :organization_types
  end

  def self.down

    create_table :organization_memberships do |t|
      t.integer :organization_id
      t.integer :jurisdiction_id
      t.integer :organization_request_id
      t.timestamps
    end

    create_table :organization_types do |t|
      t.string :name
      t.timestamps
    end
    
    change_table :organizations do |t|
      t.integer :organization_type_id
    end
    
    add_index :organization_types, :name
    add_index :organizations, :organization_type_id
  end
  
end
