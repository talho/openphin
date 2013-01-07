class CreateReportSchedule < ActiveRecord::Migration
  def change
    create_table :report_schedules do |t|
      t.string :report_type
      t.boolean :days_of_week, array: true, default: []
      t.integer :user_id

      t.timestamps
    end
  end
end
