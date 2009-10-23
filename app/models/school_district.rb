class SchoolDistrict < ActiveRecord::Base
  belongs_to :jurisdiction
  has_many :schools, :foreign_key => "district_id"
  has_many :absentee_reports, :through => :schools

  def average_absence_rate(date=nil)
    date=Date.today if date.nil?
    absentees=absentee_reports.for_date(date).map do |report|
      report.enrolled.blank? ? 0 : report.absent.to_f/report.enrolled.to_f
    end

    absentees.empty? ? 0 : (absentees.reduce(0,:+)/absentees.size).round(4)
  end
  def recent_absentee_rates(days)
    avgs=Array.new
    (Date.today-(days-1).days).upto Date.today do |date|
      avgs.push(average_absence_rate(date))
    end
    avgs
  end
end