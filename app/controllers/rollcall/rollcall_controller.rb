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
  before_filter :rollcall_required

  def index
    toolbar = current_user.roles.include?(Role.find_by_name('Rollcall')) ? "rollcall" : "application"
    Rollcall::RollcallController.app_toolbar toolbar

    @districts = current_user.jurisdictions.map(&:school_districts).flatten!
    if @districts.empty?
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
      @chart=Gchart.send(chart_type, :size => "600x400",
                         :title => "Average % Absenteeism",
                         :axis_with_labels => "x,y",
                         :axis_labels => xlabels,
#                         :max => 30,
                         :legend => @districts.map(&:name),
                         :data => @districts.map{|d| d.recent_absentee_rates(timespan).map{|m|m*100}},
#                         :custom => "chxr=1,0,30",
                         :encoding => "text"
#                         :max_value => 30
      )
      reports = current_user.recent_absentee_reports
      reports_schools = reports.map(&:school).flatten.uniq
      reports_districts = reports_schools.map(&:district).flatten.uniq
      @statistics = {}
      reports_districts.each do |district|
        @statistics[district.name] = {} unless @statistics[district.name]
        reports_schools.each do |school|
          if school.district == district
            @statistics[district.name][school.display_name] = [] unless @statistics[district.name][school.display_name]
            reports.each do |report|
              if report.school == school
                @statistics[district.name][school.display_name] << report unless @statistics[district.name][school.display_name].size  == 4
              end
            end
          end
        end
      end
    end
  end

end