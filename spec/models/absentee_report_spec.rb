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
require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe AbsenteeReport do

  describe "named_scope with_severity" do
    before(:each) do
      @normal = AbsenteeReport.create(:absent => 1, :enrolled => 100, :report_date => 1.week.ago)
      
    end
    it "should return reports with high severity" do
      report=AbsenteeReport.create(:absent => 30, :enrolled => 100, :report_date => 3.days.ago)
      AbsenteeReport.with_severity(:high).should include(report)
      AbsenteeReport.with_severity(:high).should_not include(@normal)
    end
    it "should return reports with medium severity" do
      report=AbsenteeReport.create(:absent => 20, :enrolled => 100, :report_date => 3.days.ago)
      AbsenteeReport.with_severity(:medium).should include(report)
      AbsenteeReport.with_severity(:medium).should_not include(@normal)
    end
    it "should return reports with low severity" do
      report=AbsenteeReport.create(:absent => 12, :enrolled => 100, :report_date => 3.days.ago)
      AbsenteeReport.with_severity(:low).should include(report)
      AbsenteeReport.with_severity(:low).should_not include(@normal)
    end
    it "should not return reports older than 30 days" do
      AbsenteeReport.create(:absent => 20, :enrolled => 100, :report_date => 3.days.ago)
      report=AbsenteeReport.create(:absent => 30, :enrolled => 100, :report_date => 31.days.ago)
      AbsenteeReport.with_severity(:medium).should_not include(report)
      AbsenteeReport.with_severity(:medium).should_not include(@normal)
      AbsenteeReport.with_severity(:medium).should_not be_empty
    end
  end
end
