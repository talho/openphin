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

class AbsenteeAlert < RollcallAlert
  validates_presence_of :absentee_rate
  belongs_to :absentee_report
  belongs_to :school
  belongs_to :school_district
end
