# == Schema Information
#
# Table name: school_district_daily_infos
#
#  id                 :integer(4)      not null, primary key
#  report_date        :date
#  absentee_rate      :float
#  total_enrollment   :integer(4)
#  total_absent       :integer(4)
#  school_district_id :integer(4)
#

=begin
    OpenPHIN is an opensource implementation of the CDC guidelines for 
    a public health information network.
    
    Copyright (C) 2009  Texas Association of Local Health Officials

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU Affero General Public License as
    published by the Free Software Foundation, either version 3 of the
    License, or (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU Affero General Public License for more details.

    You should have received a copy of the GNU Affero General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.

=end

class SchoolDistrictDailyInfo < ActiveRecord::Base
  belongs_to :school_district

  before_create :update_stats
  validates_presence_of :school_district
  validates_presence_of :report_date

  named_scope :for_date, lambda{|date| {
      :conditions => ["report_date = ?", date]
  }}

  def update_stats
    total_enrolled=school_district.absentee_reports.for_date(report_date).sum(:enrolled)
    if total_enrolled > 0
      write_attribute :total_enrollment,total_enrolled
      write_attribute :total_absent, school_district.absentee_reports.for_date(report_date).sum(:absent) 
      rate = school_district.absentee_reports.average("absent/enrolled",
                                                      :conditions => ["report_date = ?", report_date]
      )
      write_attribute :absentee_rate, rate.nil? || rate == 0  ? nil : rate.round(4)*100
    end

  end
end
