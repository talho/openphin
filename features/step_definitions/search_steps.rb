Given /^the sphinx daemon is running$/ do
  begin
    output = `COLUMNS=300 ps aux | grep searchd | grep cucumber`
  end while output.blank?
  output.should_not be_blank
end

Then /^I see the following users in the search results$/ do |table|
  table.raw.each do |row|
    row[0].split(',').map(&:strip).each do |name|
      response.should have_selector('#search-results .name', :content => name)
    end
  end
end

When /^I search for "([^\"]*)"$/ do |query|
  visit search_path(:q => query)
end