class AddDistributionReferenceToAlerts < ActiveRecord::Migration
  def self.up
    add_column :alerts, :distribution_reference, :string
  end

  def self.down
    remove_column :alerts, :distribution_reference
  end
end
