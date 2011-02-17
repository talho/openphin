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

When /^(?:|I )attach the file "([^"]*)" with button "([^"]*)"(?: within "([^"]*)")?$/ do |path, field, selector|
  with_scope(selector) do
    id = page.find("button", :text => field)['for']
    page.execute_script("$('##{id}').css('opacity', '100')")
    attach_file(id, File.join(RAILS_ROOT, path))
    sleep 1
  end
end

Then /^I refresh page$/ do
  execute_script("self.location.reload()")
end

Then /^I should (not )?see "([^"]*)" in an? (?:|html)editor(?: within "([^"]*)")?$/ do |not_exists, content, selector|
  with_scope(selector) do
    begin
      page.find("textarea .x-form-textarea .x-form-field .x-hidden", :text => /#{content}/)
      assert !not_exists.blank?
    rescue Capybara::ElementNotFound
      assert not_exists.blank?
    end
  end
end

Then /^(?:|I )should see "([^"]*)"(?: within "([^"]*)")? with html stripped$/ do |text, selector|
  with_scope(selector) do
    if page.respond_to? :should
      page.all(:xpath, "//*[contains(text(), '#{text.split(' ').last}')]").select{|item| item.text == text}.size.should == 1
    else
      assert page.all(:xpath, "//*[contains(text(), '#{text.split(' ').last}')]").select{|item| item.text == text}.size == 1
    end
  end
end

When /^(?:I )?(?:pause|debug)$/ do
  debugger
end

Then /^I should see html "([^\"]*)"$/ do |html|
  begin
    page.source.should =~ /#{html}/
  rescue
    raise "Could not find \"#{html}\""
  end
end

When /^I click "([^\"]*)"$/ do |arg1|
  page.find(arg1).click
end
