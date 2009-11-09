class CreateRollcallAlerts < ActiveRecord::Migration
  def self.up
    create_table :rollcall_alerts do |t|
      t.integer :severity
      t.string :type

      #absentee_alert
      t.integer :absentee_report_id
      t.integer :school_id
      t.integer :school_district_id
      t.float :absentee_rate

      t.timestamps
    end
    add_index :rollcall_alerts, :severity,      :name => :rollcall_alerts_severity
    add_index :rollcall_alerts, :absentee_rate, :name => :rollcall_alerts_rate
    add_index :rollcall_alerts, [:school_district_id, :school_id], :name => :rollcall_alerts_district_school

    execute <<-END
    insert into rollcall_alerts (type, absentee_report_id, school_id, school_district_id, absentee_rate)
      select 'AbsenteeAlert', absentee_reports.id, schools.id, schools.district_id, (absentee_reports.absent/absentee_reports.enrolled)
        from absentee_reports inner join schools on absentee_reports.school_id = schools.id
        where (absentee_reports.absent/absentee_reports.enrolled) >= 0.1100
END
       end

  def self.down
    drop_table :rollcall_alerts
  end
end
