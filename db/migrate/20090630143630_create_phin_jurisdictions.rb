class CreatePhinJurisdictions < ActiveRecord::Migration
  def self.up
    create_table :phin_jurisdictions do |t|
      t.column :name, :string
      t.column :phin_oid, :string
      t.column :description, :string
      t.column :fax, :string
      t.column :locality, :string
      t.column :postal_code, :string
      t.column :state, :string
      t.column :street, :string
      t.column :phone, :string
      t.column :county, :string
      t.column :alerting_jurisdictions, :string
      t.column :primary_organization_type, :string
      t.integer(:parent_id)
      t.integer(:lft)
      t.integer(:rgt)
      t.string(:type)
      t.timestamps
    end
  end

  def self.down
    drop_table :phin_jurisdictions
  end
end
