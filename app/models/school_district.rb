class SchoolDistrict < ActiveRecord::Base
  belongs_to :jurisdiction
  has_many :schools, :foreign_key => "district_id"
  has_many :absentee_reports, :through => :schools

  def average_absence_rate(date=nil)
    date=Date.today if date.nil?
    absentees=absentee_reports.for_date(date).map do |report|
      unless report.enrolled.blank?
        report.absent.to_f/report.enrolled.to_f
      else
        0
      end
    end
    unless absentees.empty?
      absentees.reduce(0,:+)/absentees.size
    else
      0
    end
  end
end