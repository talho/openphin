Then /^I should see an absenteeism graph with the data\:$/ do |table|
  response.should have_selector("img[src*=\"chd=t:#{table.raw.map(&:first).join(",")}\"]")
end


Then /^I should see an absenteeism summary with the data\:$/ do |table|
  table.hashes.each do |row|
    response.should have_selector(".report_date", :content => (Date.today + row["Day"].to_i.days).strftime("%Y-%m-%d"))
    response.should have_selector(".absentee_pct", :content => row["Percentage"])
  end
end
Then /^I should see an absenteeism graph with the following\:$/ do |table|
  raise "No data URL located in response body" unless response.body =~ /\{"data-file\"\:\"([^\"]*)\"/x
  url = $1.gsub(/%2F/, "/")
  values = table.is_a?(Array) ? table : table.raw
  
  in_a_separate_session do
    visit url
    json = ActiveSupport::JSON.decode(response.body)
    values.each do |row|
      property, value=row
      case property
        when /^data$/
          data_values = value.split(",").map{|v| v=="nil" ? nil : v.to_f}
          json['elements'].detect{|elm| elm["values"].map{|e| e.is_a?(Hash) ? e['value'] : e} == data_values }.should_not be_nil
        when /^data-label$/
          json['elements'].detect{|elm| elm["text"]==value}.should_not be_nil
        when /^title$/
          json['title']['text'].should == value
        when /^range$/
          min, max = value.split(',').map(&:to_f)
          json['y_axis']['min'].should == min
          json['y_axis']['max'].should == max
      end
    end
  end

end
Then /^I should see the (\d+)-day chart for "([^\"]*)" with the data:$/ do |timespan, schoolname, table|
  Then(%Q{the data at #{school_chart_path(School.find_by_display_name(schoolname), timespan)} should contain}, table)
end

Then /^the data at (\S*) should contain$/ do |url, data|
  debugger
  case data.class
    when String
      values=data.split(",").map{|val| val=="nil" ? nil : val.to_f}
    when Array
      values=data
    else
      values = table.raw.first.first.split(",").map{|val| val=="nil" ? nil : val.to_f}
  end
  in_a_separate_session do
    visit url
    json = ActiveSupport::JSON.decode(response.body)
    json['elements'][0]['values'].should == values

  end
end
