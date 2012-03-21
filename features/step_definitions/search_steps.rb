Then /^I reindex sphinx$/ do
  ThinkingSphinx::Test.index
  sleep(0.25) # Wait for Sphinx to catch up
end

Then /^I see the following users in the search results$/ do |table|
  table.raw.each do |row|
    row[0].split(',').map(&:strip).each do |name|
      page.should have_css('#search-results .name', :content => name)
    end
  end
end

Then /^I do not see the following users in the search results$/ do |table|
  table.raw.each do |row|
    row[0].split(',').map(&:strip).each do |name|
      page.should_not have_content(name)
    end
  end
end

When /^I search for "([^\"]*)"$/ do |query|
  visit show_advanced_search_path(:q => query)
end
