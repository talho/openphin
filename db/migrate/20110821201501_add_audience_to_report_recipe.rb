class AddAudienceToReportRecipe < ActiveRecord::Migration
  def self.up
    add_column :report_recipes, :audience_id, :integer
  end

  def self.down
    remove_column :report_recipes, :audience_id
  end
end
