Then /^I should see an absenteeism graph with the data\:$/ do |table|
  response.should have_selector("img[src*=\"chd=t:#{table.raw.map(&:first).join(",")}\"]")
end

Then /^I should see an absenteeism summary with the data\:$/ do |table|
  table.hashes.each do |row|
    response.should have_selector(".report_date", :content => (Date.today + row["Day"].to_i.days).strftime("%Y-%m-%d"))
    response.should have_selector(".absentee_pct", :content => row["Percentage"])
  end
end