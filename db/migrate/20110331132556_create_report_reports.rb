class CreateReportReports < ActiveRecord::Migration
  def self.up
    create_table :report_reports, :force => true do |t|
      t.integer   :author_id
      t.integer   :recipe_id
      t.boolean   :incomplete
      
      t.string    :resultset_file_name
      t.string    :resultset_content_type
      t.integer   :resultset_file_size
      t.datetime  :resultset_updated_at
      
      t.string    :rendering_file_name
      t.string    :rendering_content_type
      t.integer   :rendering_file_size
      t.datetime  :rendering_updated_at
      
      t.timestamps
    end
  end

  def self.down
#    Report::Report.all.map(&:destroy)
    drop_table :report_reports
  end

end