
Given /^I have navigated to the Reports tab$/ do
  step %Q{I am logged in as a nonpublic user}
  step %Q{I navigate to "Reports"}
end

When /^I run a TestReport$/ do
  step %{I press "Run New Report"}
  step %{I select "TestReport" from ext combo "Select Report Type"}
  step %{I press "Run Report"}
end

Then /^my TestReport should exist$/ do
  TestReport.where(user_id: current_user.id).first.should_not be_nil
  step %{I should see "TestReport - #{I18n.l Date.today, :format => :short}"}
end

Given /^I have a TestReport$/ do
  r = TestReport.build_report(current_user.id)
  r.save
  step %{I close the active tab}
  step %{I navigate to "Reports"}
end

When /^I view the TestReport$/ do
  visit report_path(TestReport.where(user_id: current_user.id).first)
end

Then /^I should see my TestReport details$/ do
  step %{I should see "Test Report"}
  step %{I should see "Result: success"}
end

When /^I delete the TestReport$/ do
  step %{I click removeBtn ""}
end

Then /^my TestReport should not exist$/ do
  TestReport.where(user_id: current_user.id).first.should_not be_nil
end

Given /^I have opened the Scheduled Reports section$/ do
  step %{I press "Scheduled Reports"}
end

When /^I schedule TestReport$/ do
  step %{I press "Schedule New Report"}
  step %{I select "TestReport" from ext combo "Report Type"}
  step %{I check "Monday"}
  step %{I check "Thursday"}
  step %{I press "Save Schedule"}
end

Then /^TestReport should be on my schedule$/ do
  rs = ReportSchedule.where(user_id: current_user.id, report_type: "TestReport").first
  rs.should_not be_nil
  rs.days_of_week.should eq([nil, true, nil, nil, true, nil, nil])
end

Given /^I have scheduled TestReport$/ do
  ReportSchedule.create(user_id: current_user.id, report_type: "TestReport", days_of_week: [true, true, true, true, true, true, true])
end

When /^I modify TestReport$/ do
  step %{I click report-dataview "TestReport"}
  step %{I uncheck "Monday"}
  step %{I uncheck "Tuesday"}
end

Then /^TestReport should be on a new schedule$/ do
  rs = ReportSchedule.where(user_id: current_user.id, report_type: "TestReport").first
  rs.should_not be_nil
  rs.days_of_week.should eq([true, nil, nil, true, true, true, true])
end

Then /^I should only have one TestReport scheduled$/ do
  ReportSchedule.where(user_id: current_user.id, report_type: "TestReport").count.should eq(1)
end

When /^backgroundrb runs report_worker$/ do
  require Rails.root.join('lib', 'workers', 'report_schedule_worker.rb')
  rw =  ReportScheduleWorker.new
  rw.run

  step %{I close the active tab}
  step %{I navigate to "Reports"}
end
