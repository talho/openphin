class AddOrganizationIdToFolder < ActiveRecord::Migration
  def change
    change_table :folders do |t|
      t.integer :organization_id
    end
  end
  
  def migrate(direction)
    super
    
    if direction == :up
      execute "UPDATE folders
               SET organization_id = organizations.id
               FROM organizations
               WHERE folders.name = organizations.name
                 AND folders.user_id IS NULL"
    end
  end
end
