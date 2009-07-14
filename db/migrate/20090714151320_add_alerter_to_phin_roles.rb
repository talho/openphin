class AddAlerterToPhinRoles < ActiveRecord::Migration
  def self.up
    add_column :roles, :alerter, :boolean
    add_index :roles, :alerter
  end

  def self.down
    remove_column :roles, :alerter
  end
end
