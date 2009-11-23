class CreateSchoolDistrictDailyInfo < ActiveRecord::Migration
  def self.up
    create_table :school_district_daily_infos do |t|
      t.date     :report_date
      t.float    :absentee_rate
      t.integer  :total_enrollment
      t.integer  :total_absent
      t.integer  :school_district_id
    end
  end

  def self.down
    drop_table :school_district_daily_infos
  end
end
