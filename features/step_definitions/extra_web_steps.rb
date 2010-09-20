When /^I will confirm on next step$/ do
  begin
    evaluate_script("self.alert = function(msg) { self.alert_message = msg; return msg; }")
    evaluate_script("self.confirm = function(msg) { self.confirmation_message = msg; return msg; }")
  rescue Capybara::NotSupportedByDriverError
  end
end

Then /^I should see "([^\"]*)" within the alert box$/ do |msg|
  message = evaluate_script("self.alert_message")
  if message.nil?
    assert false
  else
    assert !( message =~ Regexp.new(msg) ).nil?    
  end
end

Then /^I should see "([^\"]*)" within the confirmation box$/ do |msg|
  message = evaluate_script("self.confirmation_message")
  if message.nil?
    assert false
  else
    assert !( message =~ Regexp.new(msg) ).nil?
  end
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

module Capybara
  class Session
    alias_method :old_check, :check
    alias_method :old_uncheck, :uncheck
    
    def check(locator)
      field = find_field(locator)
      old_check(locator) unless field[:checked]
    end

    def uncheck(locator)
      field = find_field(locator)
      old_uncheck(locator) if field[:checked]
    end
  end
end

When /^(?:I )?pause$/ do
  debugger
end
