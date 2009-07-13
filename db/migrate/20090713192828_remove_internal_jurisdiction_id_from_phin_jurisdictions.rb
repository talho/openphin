class RemoveInternalJurisdictionIdFromPhinJurisdictions < ActiveRecord::Migration
  def self.up
    remove_column :phin_jurisdictions, :internal_jurisdiction_id
  end

  def self.down
    add_column :phin_jurisdictions, :internal_jurisdiction_id, :integer
  end
end
