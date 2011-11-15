class AddRegisteredAtToReportRecipe < ActiveRecord::Migration
  def self.up
    add_column :report_recipes, :registered_at, :timestamp, :default => nil
  end

  def self.down
    remove_column :report_recipes, :registered_at
  end
end
