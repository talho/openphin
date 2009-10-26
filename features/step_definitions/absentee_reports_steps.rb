Then /^I should see an absenteeism graph with the data\:$/ do |table|
  response.should have_selector("img[src*=\"chd=t:#{table.raw.map(&:first).join(",")}\"]")
end


Then /^I should see an absenteeism summary with the data\:$/ do |table|
  table.hashes.each do |row|
    response.should have_selector(".report_date", :content => (Date.today + row["Day"].to_i.days).strftime("%Y-%m-%d"))
    response.should have_selector(".absentee_pct", :content => row["Percentage"])
  end
end
When /^I should see an absenteeism graph with the following\:$/ do |table|
  table.raw.each do |row|
    property, value=row
    case property
      when /^data$/
        response.should have_selector("img[src*=\"chd=t:#{value}\"]")
      when /^data-label$/
        response.should have_selector("img[src*=\"chdl=#{Gchart.jstize(value)}\"]")
      when /^title$/
        response.should have_selector("img[src*=\"chtt=#{Gchart.jstize(value)}\"]")
      when /^range$/
        response.should have_selector("img[src*=\"chxr=1,#{value}\"]")
     end
  end
end