# == Schema Information
#
# Table name: rollcall_alerts
#
#  id                 :integer(4)      not null, primary key
#  severity           :integer(4)
#  type               :string(255)
#  absentee_report_id :integer(4)
#  school_id          :integer(4)
#  school_district_id :integer(4)
#  absentee_rate      :float
#  created_at         :datetime
#  updated_at         :datetime
#

class RollcallAlert < ActiveRecord::Base
end
