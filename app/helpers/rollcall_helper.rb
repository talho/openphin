module RollcallHelper

  def create_school_chart(school, timespan)
    timespan = 7 if timespan.nil?
    timespan = timespan.to_i if timespan.is_a?(String)

    school_chart=OpenFlashChart::OpenFlashChart.new("Absenteeism Rates (Last #{timespan} days)")
    school_chart.bg_colour = "#FFFFFF"

    school_absentee_points = []
    xlabels=[]
    timespan.days.ago.to_date.upto Date.today do |date|
      report=@school.absentee_reports.for_date(date).first
      school_absentee_points.push report.nil? ? nil : report.absentee_percentage
      if date.day == 1
        xlabels.push date.strftime("%B %e")
      elsif date.wday == 1
        xlabels.push date.strftime("%a (Week %W)")
      else
        xlabels.push timespan > 14 ? "" : date.strftime("%m/%d")
      end
#      xlabels.push date.wday == 1 ? date.strftime("%m/%d") : ""
    end

    school_line = OpenFlashChart::LineHollow.new
    school_line.text=@school.name
    school_line.values=school_absentee_points
    school_line.tooltip = "<b>#val# %</b> Absent"

    xa= OpenFlashChart::XAxis.new
    xa.labels=OpenFlashChart::XAxisLabels.new(:labels => xlabels, :rotate => 315, :visible_steps => 7, :size => 18)
#    xa.labels=OpenFlashChart::XAxisLabels.new(:rotate => 315, :visible_steps => timespan > 14 ? 86400*7 : 86400, :size => 18)
#    xa.steps = 86400
    xa.steps = 7
#    xa.min = timespan.days.ago.to_time.beginning_of_day.tv_sec
#    xa.max = Time.zone.now.end_of_day.tv_sec
    school_chart.set_x_axis xa

    school_chart.y_axis = OpenFlashChart::YAxis.new(
        :steps => 2,
        :min => 0,
        :max => school_absentee_points.max{|a,b| a=0 if a.nil?; b=0 if b.nil?; a <=> b}
    )

    school_chart.add_element(school_line)
    school_chart.add_element(school_bar)
    school_chart.to_s
  end

  def create_district_chart(district_s, timespan=7)
    district_s = [district_s] if district_s.is_a?(SchoolDistrict)

    #labels should be 1:week if timespan is greater than 1 week
    timespan = 7 if timespan.nil?
    timespan = timespan.to_i if timespan.is_a?(String)
    if timespan > 7
      xlabels = ((1-timespan-Date.today.wday)..0).step(7).map{|d| (Date.today+d.days).strftime("%m-%d")}.join("|")
    else
      xlabels = ((1-timespan)..0).map{|d| (Date.today+d.days).strftime("%m-%d")}.join("|")
    end
    chart=Gchart.line( :size => "500x350",
                       :title => "Average % Absenteeism (Last #{params[:timespan]} Days)",
                       :axis_with_labels => "x,y",
                       :axis_labels => xlabels,
                       :legend => district_s.map(&:name),
                       :data => district_s.map{|d| d.recent_absentee_rates(timespan).map{|m|m*100}},
                       :custom => "chdlp=b",
                       :encoding => "text"
    )
    chart
  end
end
