Given /^all email has been delivered$/ do
  ActionMailer::Base.deliveries = []
end

Then /^I should not see "(.*)" in the "(.*)" dropdown$/ do |text, label|
  field_labeled(label).element.inner_html.should_not contain(text)
end

Then /^I should explicitly not see "(.*)" in the "(.*)" dropdown$/ do |text, label|
  field_labeled(label).element.children.each do |node|
    node.inner_html.should_not == text
  end
end

Then /^I should see "(.*)" in the "(.*)" dropdown$/ do |text, label|
  field_labeled(label).element.inner_html.should contain(text)
end

Then /^I should explicitly see "(.*)" in the "(.*)" dropdown$/ do |text, label|
  field_labeled(label).element.children.each do |node|
    node.inner_html.should == text
  end
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

Then /^I should not see an "([^\"]+)" button$/ do |button_text|
  response.should_not have_selector('input[type=button]', :content => button_text)
end

Then /^I should see the following menu\:$/ do |table|
	name = table.raw[0][1]
	response.should have_selector("##{name}") do |menu|
		table.rows.each do |row|
			key, value = row[0], row[1]
			case key
				when "item"
					menu.should have_selector("li a", :content => value)
        when "current item"
          menu.should have_selector("li.current a", :content => value)
        else
          raise "I don't know what '#{key}' means, please fix the step definition in #{__FILE__}"
 			end
		end
	end

end
Then /^I should see (\d*) "([^\"]+)" sections$/ do |count, section|
	response.should have_selector(".#{section}", :count => count.to_i)
end
