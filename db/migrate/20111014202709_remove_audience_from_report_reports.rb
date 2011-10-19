class RemoveAudienceFromReportReports < ActiveRecord::Migration
  def self.up
    remove_column :report_reports, :audience_id
  end

  def self.down
    add_column :report_reports, :audience_id, :integer
  end
end
