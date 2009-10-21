class RenameSchoolAbsenceReportsToAbsenteeReports < ActiveRecord::Migration
  def self.up
    rename_table :school_absence_reports, :absentee_reports
  end

  def self.down
    rename_table :absentee_reports, :school_absence_reports
  end
end
