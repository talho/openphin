class ChangeRecipeFromReferenceToStringInReportReports < ActiveRecord::Migration
  def self.up
    remove_column :report_reports, :recipe_id
    add_column :report_reports, :recipe, :string
  end

  def self.down
    add_column :report_reports, :recipe_id, :integer
    remove_column :report_reports, :recipe
  end
end
