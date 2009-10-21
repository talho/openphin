Given /^(.*) has the following school districts:$/ do |jurisdiction, table|
  table.raw.each do |row|
    Factory(:school_district, :name => row[0], :jurisdiction => Jurisdiction.find_by_name!(jurisdiction))
  end
end

Given /^"([^\"]*)" has the following schools:$/ do |isd, table|
  table.hashes.each do |row|
    Factory(:school, :name => row["Name"],
            :display_name => row["DisplayName"],
            :school_number => row["SchoolID"],
            :address => row["Address"],
            :postal_code => row["Zipcode"],
            :level => row["Level"],
            :district => SchoolDistrict.find_by_name!(isd))
  end
end

Given /^"([^\"]*)" has the following current absenteeism data:$/ do |isd, table|
  table.hashes.each do |row|
#    row["Date"] = Date.today.strftime("%Y-%m-%d") if row["Date"] == "today"
    date=Date.today + row["Day"].to_i.days
    AbsenteeReport.create!(:school => School.find_by_name!(row["SchoolName"]),
                                :report_date => "#{date} 00:00:00",
                                :enrolled => row["Enrolled"],
                                :absent => row["Absent"])
  end
end
Then /^I should see an absenteeism summary with the data\:$/ do |table|
  table.hashes.each do |row|
    response.should have_selector(".report_date", :content => (Date.today + row["Day"].to_i.days).strftime("%Y-%m-%d"))
    response.should have_selector(".absentee_pct", :content => row["Percentage"])
  end
end