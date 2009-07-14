class AddAlerterToPhinRoles < ActiveRecord::Migration
  def self.up
    add_column :phin_roles, :alerter, :boolean
    add_index :phin_roles, :alerter
  end

  def self.down
    remove_column :phin_roles, :alerter
  end
end
