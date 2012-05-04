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

Then /^I should see the following jurisdictions:$/ do |table|
  table.raw.each do |row|
    #response.should have_selector(".jurisdictions *", :content => row[0])
    within(:css, ".jurisdictions") { page.should have_content(row[0]) }
  end
end
Given /^(\d*) jurisdictions that are children of (.*)$/ do |count, parent|
  pj = Jurisdiction.find_by_name(parent)
  count.to_i.times do
    j=FactoryGirl.create(:jurisdiction)
    j.move_to_child_of(pj)
  end
end

Given /^a few jurisdictions$/ do
  step "the following entities exist:", table(%{
    | Jurisdiction | Texas      |
    | Jurisdiction | Travis     |
    | Jurisdiction | Williamson |
  });
  step %Q{Texas is the parent jurisdiction of:}, table([
    %w{Travis},
    %w{Williamson}
  ]);
end

