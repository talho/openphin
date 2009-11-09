class AddIndexesToAbsenteeReportsAndSchools < ActiveRecord::Migration
  def self.up
    add_index :absentee_reports, [:school_id, :report_date], :name => :absentee_reports_school_id_report_date
    add_index :schools, :name, :name => :schools_name
    add_index :schools, :display_name, :name => :schools_display_name
  end

  def self.down
    remove_index :absentee_reports, :absentee_reports_school_id_report_date
    remove_index :schools_name
    remove_index :schools_display_name
  end
end
