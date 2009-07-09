class AddSecurityAttributeToRole < ActiveRecord::Migration
  def self.up
    add_column :phin_roles, :approval_required, :string
  end

  def self.down
    remove_column :phin_roles, :approval_required
  end
end
