class ChangeAbsenteeReportsReportDateToDate < ActiveRecord::Migration
  def self.up
    change_column :absentee_reports, :report_date, :date
  end

  def self.down
    change_column :absentee_reports, :report_date, :datetime
  end
end
