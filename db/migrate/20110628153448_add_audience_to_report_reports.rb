class AddAudienceToReportReports < ActiveRecord::Migration
  def self.up
    add_column :report_reports, :audience, :integer
  end

  def self.down
    remove_column :report_reports, :audience
  end
end
