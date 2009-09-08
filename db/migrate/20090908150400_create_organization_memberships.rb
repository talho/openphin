class CreateOrganizationMemberships < ActiveRecord::Migration
  def self.up
    create_table :organization_memberships do |t|
      t.integer :organization_id
      t.integer :jurisdiction_id
      t.integer :organization_request_id
      t.timestamps
    end
  end

  def self.down
    drop_table :organization_memberships
  end
end
