class AddForeignToOrganizations < ActiveRecord::Migration
  def self.up
    add_column :jurisdictions, :foreign, :boolean
  end

  def self.down
    remove_column :jurisdictions, :foreign
  end
end
