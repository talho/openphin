class AddOrganizationPropertiesToJurisdiction < ActiveRecord::Migration
  def self.up
      add_column :phin_jurisdictions, :internal_jurisdiction_id, :integer
  end

  def self.down
      remove_column :phin_jurisdictions, :internal_jurisdiction_id
  end
end
