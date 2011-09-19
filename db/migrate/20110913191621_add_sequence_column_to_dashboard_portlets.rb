class AddSequenceColumnToDashboardPortlets < ActiveRecord::Migration
  def self.up
    add_column :dashboards_portlets, :sequence, :integer, :default => 0
  end

  def down
    remove_column :dashboards_portlets, :sequence
  end
end
