When /^I will confirm on next step$/ do
  begin
    evaluate_script("self.alert = function(msg) { window.alert_message = msg; return msg; }")
    evaluate_script("self.confirm = function(msg) { window.confirmation_message = msg; return msg; }")
  rescue Capybara::NotSupportedByDriverError
  end
end

Then /^I should see "([^\"]*)" within the alert box$/ do |msg|
  message = wait_until do
    evaluate_script("window.alert_message")
  end
  if message.nil?
    assert false
  else
    assert !( message =~ Regexp.new(msg) ).nil?    
  end
end

Then /^I should see "([^\"]*)" within the confirmation box$/ do |msg|
  message = evaluate_script("window.confirmation_message")
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
    page.execute_script("self.alert = function(msg) { self.alert_message = msg; return msg; }")
  rescue Capybara::NotSupportedByDriverError
  end
end

When /^(?:|I )attach the file "([^"]*)" with button "([^"]*)"(?: within "([^"]*)")?$/ do |path, field, selector|
  with_scope(selector) do
    id = waiter do
      page.find("button", :text => field)['for']
    end
    page.execute_script("$('##{id}').css('opacity', '100')")
    attach_file(id, File.join(RAILS_ROOT, path))
    sleep 1
  end
end

Then /^I refresh page$/ do
  page.execute_script("self.location.reload()")
end

Then /^I should (not )?see "([^"]*)" in an? (?:|html)editor(?: within "([^"]*)")?$/ do |not_exists, content, selector|
  with_scope(selector) do
    result = waiter do
      page.find("textarea .x-form-textarea .x-form-field .x-hidden", :text => /#{content}/)
    end

    if not_exists
      result.should be_nil
    else
      result.should_not be_nil
    end
  end
end

Then /^(?:|I )should see "([^"]*)"(?: within "([^"]*)")? with html stripped$/ do |text, selector|
  with_scope(selector) do
    waiter do
      page.all(:xpath, "//*[contains(text(), '#{text.split(' ').last}')]")
    end.select{|item| item.text == text}.size.should == 1
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

When /^I visit the url "([^"]*)"$/ do |page_url|
   visit page_url
end

When /^I suspend cucumber/ do
  print "Cucumber suspended: press Return to continue"
  STDIN.getc
end

When /^I wait for (\d+) seconds?$/ do |secs|
  print "Cucumber suspended for #{secs} seconds..."
  sleep secs.to_i
end

When /^I maliciously post formdata .+ "([^"]*)"$/ do | url, table |
  script = "form = document.createElement('form'); form.setAttribute('method', 'POST'); form.setAttribute('action', '#{url}');"
  table.rows_hash.each do |name, value|
    script += "hiddenField = document.createElement('input'); hiddenField.setAttribute('type', 'hidden'); hiddenField.setAttribute('name', '#{name}'); hiddenField.setAttribute('value', '#{value}'); form.appendChild(hiddenField);"
  end
  script += "document.body.appendChild(form); form.submit();"
  page.execute_script(script)
end

When /^I maliciously (.+) data .+ "([^"]*)"$/ do | method, url, table |
  script = "xhr = new XMLHttpRequest(); " +
          "xhr.open('#{method.upcase}','#{url}?#{table.rows_hash.to_query}',true); "+
          "xhr.send(); "
  page.execute_script(script)
end
