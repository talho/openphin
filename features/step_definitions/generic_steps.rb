Given /^all email has been delivered$/ do
  ActionMailer::Base.deliveries = []
end


Given /^the following file "([^\"]*)":$/ do |filename, text|
  file=File.open(File.join(Rails.root, "tmp",filename), "w+")
  file.write(text)
  file.close
end

Then /^"([^\"]*)" should have (\d*) emails?$/ do |email,count|
  [find_email(email)].flatten.size.should == count.to_i
end  

Then /^I should not see "(.*)" in the "(.*)" dropdown$/ do |text, label|
  find_field(label).all(:xpath, ".//option").map(&:text).select{|item| item =~ Regexp.new(text)}.flatten.blank?.should be_true
end

Then /^I should explicitly not see "(.*)" in the "(.*)" dropdown$/ do |text, label|
  find_field(label).find(:xpath, ".//option[.='#{text}']").should be_nil
end

Then /^I should see "(.*)" in the "(.*)" dropdown$/ do |text, label|
  find_field(label).all(:xpath, ".//option").map(&:text).select{|item| item =~ Regexp.new(text)}.flatten.blank?.should be_false
end

Then /^I should explicitly see "(.*)" in the "(.*)" dropdown$/ do |text, label|
  field = find_field(label).find(:xpath, ".//option[.='#{text}']")
  field.should_not be_nil
  field.text.should == text
end

When /^I fill in the form with the following info:$/ do |table|
	table.raw.each do |row|
		if ["Preferred language"
# Add in more select form elements here
		].include?(row[0])
			When "I select \"#{row[1]}\" from \"#{row[0]}\""
    else
      When "I fill in \"#{row[0]}\" with \"#{row[1]}\""
		end
	end
end

When /^I fill in the ext form with the following info:$/ do |table|
	table.raw.each do |row|
		if ["Language"
# Add in more select form elements here
		].include?(row[0])
			When "I select \"#{row[1]}\" from ext combo \"#{row[0]}\""
    else
      When "I fill in \"#{row[0]}\" with \"#{row[1]}\""
		end
	end
end

Then /^I should see a link to (.*)$/ do |page_name|
  response.should have_selector('a', :content => page_name)
end

Then /^I should see a "([^\"]+)" submit button$/ do |button_text|
  response.should have_selector("input [type=submit] [value=#{button_text}]")
end

Then /^I should not see a link to (.*)$/ do |page_name|
  response.should_not have_selector('a', :content => page_name)
end

Then /^I should see a "([^\"]*)" link$/ do |class_name|
  page.should have_link(class_name)
end

Then /^I should not see a "([^\"]*)" link$/ do |class_name|
  page.should_not have_link(class_name)
end

Then /^I should not see an "([^\"]+)" button$/ do |button_text|
  assert page.find('input', :content => button_text).nil? == true
end

Then /^I should see the following menu\:$/ do |table|
  name = table.raw[0][1]
  within(:css, "##{name}") do
    table.rows.each do |row|
      key, value = row[0], row[1]
      case key
        when "item"
          within(:css, "li a") { page.should have_content(value) }
        when "current item"
          within(:css, "li.current a") { page.should have_content(value) }
        else
          raise "I don't know what '#{key}' means, please fix the step definition in #{__FILE__}"
        end
    end
    false
  end
end

Then /^I should see (\d*) "([^\"]+)" sections$/ do |count, section|
	response.should have_selector(".#{section}", :count => count.to_i)
end

Then /^"([^"]*)" should be implemented$/ do |arg1|
  pending arg1
end