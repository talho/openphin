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

