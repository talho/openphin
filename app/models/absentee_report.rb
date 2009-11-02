# == Schema Information
#
# Table name: absentee_reports
#
#  id          :integer(4)      not null, primary key
#  school_id   :integer(4)
#  report_date :date
#  enrolled    :integer(4)
#  absent      :integer(4)
#  created_at  :datetime
#  updated_at  :datetime
#

class AbsenteeReport < ActiveRecord::Base
  belongs_to :school
  has_one :district, :through => :school

  named_scope :for_date, lambda{ |date|
    {
      :conditions => {:report_date => date}
    }
  }
  named_scope :for_date_range, lambda{ |start, finish|
    {
      :conditions => ["report_date >= ? and report_date <= ?", start, finish]
    }
  }
  named_scope :recent, lambda{|limit| {:limit => limit, :order => "report_date DESC"}}
  named_scope :absenses, lambda{{:conditions => ['absentee_reports.absent / absentee_reports.enrolled >= .11']}}
  def absentee_percentage
    ((absent.to_f / enrolled.to_f) * 100).to_f.round(2)
  end

  def severity
    return "low" if absentee_percentage >= 11.0 && absentee_percentage <= 13.99
    return "medium" if absentee_percentage >= 14.0 && absentee_percentage <= 24.99
    return "high" if absentee_percentage >= 25
  end
end
