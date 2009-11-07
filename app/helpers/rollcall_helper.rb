module RollcallHelper
  def create_school_chart(school, timespan)
    timespan = 7 if timespan.nil?
    timespan = timespan.to_i if timespan.is_a?(String)

    if timespan > 7
      xlabels = ((1-timespan-Date.today.wday)..0).step(7).map{|d| (Date.today+d.days).strftime("%m-%d")}.join("|")
    else
      xlabels = ((1-timespan)..0).map{|d| (Date.today+d.days).strftime("%m-%d")}.join("|")
    end
    school_absentee_points = []
    timespan.days.ago.to_date.upto Date.today do |date|
      report=@school.absentee_reports.for_date(date).first
      school_absentee_points.push report.nil? ? 0 : report.absentee_percentage
    end
    school_chart=Gchart.line(:size => "500x350",
                             :title => "Recent Absenteeism (Last #{params[:timespan]} Days)",
                             :axis_with_labels => "x,y",
                             :axis_labels => xlabels,
                             :legend => @school.display_name,
                             :data => school_absentee_points,
                             :custom => "chdlp=b",
                             :encoding => "text"
    )
    school_chart
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
