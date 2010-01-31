class AddStatisticsToAlert < ActiveRecord::Migration
  def self.up
    add_column :alerts, :statistics, :text
  end

  def self.down
    remove_column :alerts, :statistics
  end
end
