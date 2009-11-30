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
  helper :rollcall

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
    end
    @chart=open_flash_chart_object(600, 300, rollcall_summary_chart_path(params[:timespan]))

  end



  ##data for summary chart on rollcall index
  def summary_chart
    timespan = params[:timespan].nil? ? 7 : params[:timespan].to_i

    summary_chart=OpenFlashChart.new("Absenteeism Rates (Last #{timespan} days)")
    summary_chart.bg_colour = "#FFFFFF"

    lines=current_user.school_districts.map do |d|
      line=LineHollow.new
      line.text = d.name
      line.values = recent_data(d, timespan)
      line
    end
    max=current_user.school_districts.map{|d| d.recent_absentee_rates(timespan).max{|a,b| a=0 if a.nil?; b=0 if b.nil?; a <=> b} }.max
    xa= XAxis.new
    xa.labels=XAxisLabels.new(:labels => generate_time_labels(timespan), :rotate => 315, :visible_steps => 7, :size => 18)
    xa.steps = 7
    summary_chart.set_x_axis xa

    summary_chart.y_axis = YAxis.new(
        :steps => 2,
        :min => 0,
        :max => max
    )

    lines.each do |l|
      summary_chart.add_element(l)
    end
    render :text => summary_chart.to_s, :layout => false
  end

  private
  def recent_data(district, timespan)
    data = []
    (timespan-1).days.ago.to_date.upto Date.today do |date|
      rate=district.average_absence_rate(date)
      data.push rate.nil? ? nil : DotValue.new(district.average_absence_rate(date), nil, :tip => "#{date.strftime("%x")}\n#val#%")
    end
    data
  end
  def generate_time_labels(timespan)
    xlabels=[]
    timespan.days.ago.to_date.upto Date.today do |date|
      if date.day == 1
        #label beginning of month
        xlabels.push date.strftime("%B %e")
      elsif date.wday == 1
        #label beginning of week
        xlabels.push date.strftime("%a (Week %W)")
      else
        xlabels.push timespan > 14 ? "" : date.strftime("%m/%d")
      end
    end
    xlabels
  end

end
