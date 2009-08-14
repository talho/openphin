require File.expand_path(File.join(File.dirname(__FILE__), "..", "support", "paths"))

Then /^the "([^\"]*)" class selector should contain "([^\"]*)"$/ do |field, value|
  response.should have_selector("*", :class => field, :content => value)
end