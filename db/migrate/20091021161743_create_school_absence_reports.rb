class CreateSchoolAbsenceReports < ActiveRecord::Migration
  def self.up
    create_table :school_absence_reports do |t|
      t.integer :school_id
      t.datetime :report_date
      t.integer :enrolled
      t.integer :absent
      t.timestamps
    end
  end

  def self.down
    drop_table :school_absence_reports
  end
end
