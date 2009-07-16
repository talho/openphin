class AddOrganizationIdToDeliveries < ActiveRecord::Migration
  def self.up
    add_column :deliveries, :organization_id, :integer
  end

  def self.down
    remove_column :deliveries, :organization_id
  end
end
