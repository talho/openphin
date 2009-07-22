Then /^I should not see "(.*)" in the "(.*)" dropdown$/ do |text, label|
  field_labeled(label).element.inner_html.should_not contain(text)
end

Then /^I should see "(.*)" in the "(.*)" dropdown$/ do |text, label|
  field_labeled(label).element.inner_html.should contain(text)
end

When /^I fill in the form with the following info:$/ do |table|
	table.raw.each do |row|
		if ["Preferred language"
# Add in more select form elements here
		].include?(row[0])
			select  row[1], row[0]
		else
			fill_in row[0], row[1]
		end
	end
end

Then /^I should see a link to (.*)$/ do |page_name|
  response.should have_selector('a', :content => page_name)
end

Then /^I should not see a link to (.*)$/ do |page_name|
  response.should_not have_selector('a', :content => page_name)
end

Then /^I should see a (.*) link$/ do |class_name|
  response.should have_selector('a', :class => ".#{class_name}")
end

Then /^I should not see a (.*) link$/ do |class_name|
  response.should_not have_selector('a', :class => ".#{class_name}")
end