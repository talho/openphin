class AddNameAndDatasetSizeAndDatasetUpdatedAtToReportReports < ActiveRecord::Migration
  def self.up
    add_column :report_reports, :name, :string
    add_column :report_reports, :dataset_size, :integer
    add_column :report_reports, :dataset_updated_at, :datetime
  end

  def self.down
   remove_column :report_reports, :name
   remove_column :report_reports, :dataset_size
   remove_column :report_reports, :dataset_updated_at
  end
end

