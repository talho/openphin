When /^I will confirm on next step$/ do
  begin
    evaluate_script("window.alert = function(msg) { window.alert_message = msg; return msg; }")
    evaluate_script("window.confirm = function(msg) { window.confirmation_message = msg; return msg; }")
  rescue Capybara::NotSupportedByDriverError
  end
end

Then /^I should see "([^\"]*)" within the alert box$/ do |msg|
  assert !(evaluate_script("window.alert_message") =~ Regexp.new(msg)).nil?
end

Then /^I should see "([^\"]*)" within the confirmation box$/ do |msg|
  assert !(evaluate_script("window.confirmation_message") =~ Regexp.new(msg)).nil?
end

When /^I close "([^\"]*)" modal box$/ do |dom_selector|
  begin
    evaluate_script("$('#{dom_selector}').dialog('close');")
  rescue
    Capybara::NotSupportedByDriverError
  end
end

When /^I override alert$/ do
  begin
    evaluate_script("window.alert = function(msg) { window.alert_message = msg; return msg; }")
  rescue Capybara::NotSupportedByDriverError
  end
end

Then /^I refresh page$/ do
  evaluate_script("window.location.reload()")
end
When /^I pause$/ do
  debugger
end