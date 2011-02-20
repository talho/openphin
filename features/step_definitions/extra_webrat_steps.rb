require File.expand_path(File.join(File.dirname(__FILE__), "..", "support", "paths"))

When /^I specifically go to ([^\"]*) for "([^\"]*)"$/ do |page_name, arg|
  visit path_to(page_name, arg)
end

Then /^the "([^\"]*)" class selector should contain "([^\"]*)"$/ do |field, value|
  waiter do
    page.find(".#{field}", :text => value)
  end.should_not be_nil
end

Then /^the "([^\"]*)" class selector should not contain "([^\"]*)"$/ do |field, value|
  waiter do
    page.find(".#{field}", :text => value)
  end.should be_nil
end

Then /^I should see the link "([^\"]*)" that goes to "([^\"]*)"$/ do |value, link|
  within("a[href='#{link}'") do
    page.should have_content(value)
  end
end

Then /^I should not see the link "([^\"]*)"$/ do |value|
  within("a") do
    page.should_not have_content(value)
  end
end

Then /^I should be specifically on (.+) for "([^\"]*)"$/ do |page_name, arg|
  URI.parse(current_url).path.should == path_to(page_name, arg)
end

Then /^I should explictly see "([^\"]*)" within "([^\"]*)"$/ do |regexp, selector|
  regexp = Regexp.new(/^#{regexp}$/)
  page.should have_css(selector, :text => regexp)
end

Then /^I should see "([^\"]*)" in the response header flash error$/ do |text|
  within(".flash .error") do
    page.should have_content(text)
  end
end
