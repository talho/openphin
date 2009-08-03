class AddContactInfoToOrganization < ActiveRecord::Migration
  def self.up
    add_column :organizations, :contact_display_name, :string
    add_column :organizations, :contact_phone, :string
    add_column :organizations, :contact_email, :string
  end

  def self.down
    remove_column :organizations, :contact_display_name
    remove_column :organizations, :contact_phone
    remove_column :organizations, :contact_email
  end
end
