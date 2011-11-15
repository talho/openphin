class AddCriteriaToReportReports < ActiveRecord::Migration
  def self.up
    add_column :report_reports, :criteria, :text
  end

  def self.down
    remove_column :report_reports, :criteria
  end
end
