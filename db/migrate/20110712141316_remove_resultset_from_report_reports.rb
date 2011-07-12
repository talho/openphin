class RemoveResultsetFromReportReports < ActiveRecord::Migration
  def self.up
    Report::Report.all.map(&:destroy)
    remove_column :report_reports, :resultset_file_name
    remove_column :report_reports, :resultset_content_type
    remove_column :report_reports, :resultset_file_size
    remove_column :report_reports, :resultset_updated_at
  end

  def self.down
    add_column :report_reports, :resultset_file_name, :string
    add_column :report_reports, :resultset_content_type, :string
    add_column :report_reports, :resultset_file_size, :integer
    add_column :report_reports, :resultset_updated_at, :datetime
  end
end
