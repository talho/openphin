class CreateOrganizationRequest < ActiveRecord::Migration
  def self.up
    create_table :organization_requests do |t|
      t.integer :organization_id
      t.integer :jurisdiction_id
      t.boolean :approved, :default => false, :null => false
      t.integer :approver_id
      t.timestamps
    end
  end

  def self.down
    drop_table :organization_requests
  end
end
