class AddQueueToOrganizations < ActiveRecord::Migration
  def self.up
    add_column :jurisdictions, :queue, :string
  end

  def self.down
    remove_column :jurisdictions, :queue
  end
end
