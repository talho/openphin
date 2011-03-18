Given /^(.*) is a foreign jurisdiction$/ do | name |
  j=Jurisdiction.find_or_create_by_name(name)
  j.foreign=true
  j.save
end

Given /^the following FIPS codes exist\:$/ do |table |
  table.rows_hash.each do |jurisdiction, fips|
    j=Jurisdiction.find_by_name(jurisdiction)
    j.fips_code = fips
    j.save
  end
end

Given /^([^\"]*) is a state$/ do |name|
  j = Jurisdiction.find_by_name name
  j.update_attribute "state", true
end

Then /^I should see "(.*)" as a jurisdictions option$/ do |name|
  jurisdiction = Jurisdiction.find_by_name!(name)
  assert page.find("input.audience_jurisdiction[@value=\"#{jurisdiction.id.to_s}\"]").nil? == false
end

Then /^I should see "(.*)" as a from jurisdiction option$/ do |name|
  jurisdiction = Jurisdiction.find_by_name!(name)
  assert page.find("select#han_alert_from_jurisdiction_id option[@value=\"#{jurisdiction.id.to_s}\"]").nil? == false
end

Then /^I should not see "(.*)" as a from jurisdiction option$/ do |name|
  jurisdiction = Jurisdiction.find_by_name!(name)
  begin
    wait_until do
      begin
        page.find("select#han_alert_from_jurisdiction_id option[@value=\"#{jurisdiction.id.to_s}\"]").nil?
        assert false
      rescue Capybara::ElementNotFound
      end
    end
  rescue Capybara::TimeoutError
    assert true
  end
end

Then /^I should see the following jurisdictions:$/ do |table|
  table.raw.each do |row|
    #response.should have_selector(".jurisdictions *", :content => row[0])
    within(:css, ".jurisdictions") { page.should have_content(row[0]) }
  end
end
Given /^(\d*) jurisdictions that are children of (.*)$/ do |count, parent|
  pj = Jurisdiction.find_by_name(parent)
  count.to_i.times do
    j=Factory(:jurisdiction)
    j.move_to_child_of(pj)
  end
end

