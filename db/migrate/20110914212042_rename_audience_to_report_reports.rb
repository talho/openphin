class RenameAudienceToReportReports < ActiveRecord::Migration
  def self.up
    rename_column :report_reports, :audience, :audience_id
  end

  def self.down
    rename_column :report_reports, :audience_id, :audience
  end
end
