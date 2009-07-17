class AddApprovedToOrganizations < ActiveRecord::Migration
  def self.up
    add_column :organizations, :approved, :boolean, :default => false
  end

  def self.down
    remove_column :organizations, :approved
  end
end
