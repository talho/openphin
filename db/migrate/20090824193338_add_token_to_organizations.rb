class AddTokenToOrganizations < ActiveRecord::Migration

  def self.up
    add_column :organizations, :token, :string, :limit => 128
    add_column :organizations, :email_confirmed, :boolean, :default => false, :null => false
  end

  def self.down
    remove_column :organizations, :token
    remove_column :organizations, :email_confirmed
  end

end
