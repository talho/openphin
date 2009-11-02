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

class Rollcall::RollcallController < ApplicationController
  app_toolbar "rollcall"

  before_filter :rollcall_required, :except => :about

  def about
  end

  def index
    toolbar = current_user.roles.include?(Role.find_by_name('Rollcall')) ? "rollcall" : "application"
    Rollcall::RollcallController.app_toolbar toolbar

    @districts = current_user.jurisdictions.map(&:school_districts).flatten!
    if @districts.empty? || !current_user.roles.include?(Role.find_by_name('Rollcall'))
      flash[:notice] = "You do not currently have any school districts in your jurisdiction enrolled in Rollcall.  Email your OpenPHIN administrator for more information."
      render "about"
    else

      params[:timespan]="7" if params[:timespan].blank?
      chart_type=params[:chart_type] == "bar" ? "bar" : "line"
      timespan=params[:timespan].to_i

      #labels should be 1:week if timespan is greater than 1 week
      if timespan > 7
        xlabels = ((1-timespan-Date.today.wday)..0).step(7).map{|d| (Date.today+d.days).strftime("%m-%d")}.join("|")
      else
        xlabels = ((1-timespan)..0).map{|d| (Date.today+d.days).strftime("%m-%d")}.join("|")
      end
      @chart=Gchart.send(chart_type, :size => "500x350",
                         :title => "Average % Absenteeism",
                         :axis_with_labels => "x,y",
                         :axis_labels => xlabels,
                         :legend => @districts.map(&:name),
                         :data => @districts.map{|d| d.recent_absentee_rates(timespan).map{|m|m*100}},
                         :custom => "chdlp=b",
                         :encoding => "text"
      )
      ethans_crazy_absenteeism_summary_code
    end
  end

  private
  def ethans_crazy_absenteeism_summary_code
    reports = current_user.recent_absentee_reports
    reports_schools = reports.map(&:school).flatten.uniq
    reports_districts = reports_schools.map(&:district).flatten.uniq
    @statistics = {}
    stat = {}
    reports_districts.each do |district|
      stat[district.name] = {} unless stat[district.name]
      reports_schools.each do |school|
        if school.district == district
          stat[district.name][school.display_name] = [] unless stat[district.name][school.display_name]
          reports.each do |report|
            if report.school == school
              stat[district.name][school.display_name] << report
              stat[district.name][school.display_name] = stat[district.name][school.display_name].sort{|a, b| b.absentee_percentage <=> a.absentee_percentage}
            end
          end
        end
      end
    end
    stat.each do |district_name, district|
      district.each do |school_name, school|
        stat[district_name][school_name] = school[0..3]
      end
    end
    stat.each do |district_name, district|
      @statistics[district_name] = {} unless @statistics[district_name]
      @statistics[district_name] = district.sort{|a, b|
        stat[district_name][b.first].first.absentee_percentage <=> stat[district_name][a.first].first.absentee_percentage
      }
    end
  end
end
