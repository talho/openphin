Then /^I should see "(.*)" as a jurisdictions option$/ do |name|
  jurisdiction = Jurisdiction.find_by_name!(name)
  response.should have_selector("input[name='alert[jurisdiction_ids][]']", :value => jurisdiction.id.to_s)
end

Then /^I should see "(.*)" as a from jurisdiction option$/ do |name|
  jurisdiction = Jurisdiction.find_by_name!(name)
  response.should have_selector("select[name*=from_jurisdiction_id] option", :value => jurisdiction.id.to_s)
end

Then /^I should not see "(.*)" as a from jurisdiction option$/ do |name|
  jurisdiction = Jurisdiction.find_by_name!(name)
  response.should_not have_selector("select[name*=from_jurisdiction_id] option", :value => jurisdiction.id.to_s)
end
