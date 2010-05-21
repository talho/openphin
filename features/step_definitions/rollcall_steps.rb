When /^I drop the following file in the rollcall directory\:$/ do |erb_file_template|
  rollcall_drop_dir=File.join(File.dirname(__FILE__), '..', '..', 'tmp', 'rollcall')
  Dir.ensure_exists(rollcall_drop_dir)
  file=ERB.new(erb_file_template.gsub("|", "\t")).result
  f=File.open(File.join(rollcall_drop_dir, 'Attendance_test.txt'), 'w')
  f.write(file)
  f.close
end
When /^the rollcall background worker processes$/ do
  RollcallDataImporter.process_uploads
end

Then /^I should not see a rollcall alert for "([^\"]*)"$/ do |school|
  response.should_not have_selector(".school", :content => school)
end

Then /^I should see an "([^\"]*)" rollcall summary for "([^\"]*)" with (.*) absenteeism$/ do |severity, school, percent|
  response.should have_selector(".rollcall_summary") do |elm|
    elm.should have_selector(".school", :content => school) do |elm2|
      elm2.should have_selector(".#{severity}") do |elm3|
        elm3.should have_selector(".absence", :content => percent)
      end
    end
  end
end

Then /^I should see school data for "([^\"]*)"$/ do |school|
  response.should have_selector(".school_data") do |elm|
    elm.should have_selector(".school", :content => school)
  end
end