class AddFieldsToOrganizations < ActiveRecord::Migration
  def self.up
    add_column :organizations, :distribution_email, :string
    add_column :organizations, :contact_id, :integer
    remove_column :organizations, :county
    
    create_table :jurisdictions_organizations, :id => false do |t|
      t.references :jurisdiction
      t.references :organization
    end
  end

  def self.down
    remove_column :organizations, :contact_id
    remove_column :organizations, :distribution_email
    add_column :organizations, :county, :string
    drop_table :jurisdictions_organizations
  end
end
