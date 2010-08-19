When /^I will confirm on next step$/ do
  begin
    evaluate_script("self.alert = function(msg) { self.alert_message = msg; return msg; }")
    evaluate_script("self.confirm = function(msg) { self.confirmation_message = msg; return msg; }")
  rescue Capybara::NotSupportedByDriverError
  end
end

Then /^I should see "([^\"]*)" within the alert box$/ do |msg|
  assert !(evaluate_script("self.alert_message") =~ Regexp.new(msg)).nil?
end

Then /^I should see "([^\"]*)" within the confirmation box$/ do |msg|
  assert !(evaluate_script("self.confirmation_message") =~ Regexp.new(msg)).nil?
end

When /^I close "([^\"]*)" modal box$/ do |dom_selector|
  begin
    execute_script("$('#{dom_selector}').dialog('close');")
  rescue
    Capybara::NotSupportedByDriverError
  end
end

When /^I override alert$/ do
  begin
    evaluate_script("self.alert = function(msg) { self.alert_message = msg; return msg; }")
  rescue Capybara::NotSupportedByDriverError
  end
end

Then /^I refresh page$/ do
  execute_script("self.location.reload()")
end