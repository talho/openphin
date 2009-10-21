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

Given /^"([^\"]*)" has the following absenteeism data:$/ do |isd, table|
  table.hashes.each do |row|
    row["Date"] = Date.today.strftime("%Y-%m-%d") if row["Date"] == "today"
    SchoolAbsenseReport.create!(:school => School.find_by_name!(row["SchoolName"]),
                                :report_date => '#{row["Date"] row["Time"]}',
                                :enrolled => row["Enrolled"],
                                :absent => row["Absent"])
  end
end