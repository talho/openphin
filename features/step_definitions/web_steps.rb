# IMPORTANT: This file is generated by cucumber-rails - edit at your own peril.
# It is recommended to regenerate this file in the future when you upgrade to a 
# newer version of cucumber-rails. Consider adding your own code to a new file 
# instead of editing this one. Cucumber will automatically load all features/**/*.rb
# files.


require 'uri'
require 'cgi'
require File.expand_path(File.join(File.dirname(__FILE__), "..", "support", "paths"))

module WithinHelpers
  def with_scope(locator)
    locator.blank? ? yield : within(locator) { yield }
  end

  def waiter
    begin
      wait_until do
        begin
          yield
        rescue Capybara::ElementNotFound, Selenium::WebDriver::Error::ObsoleteElementError
        end
      end
    rescue Capybara::TimeoutError
      return nil
    end
  end
end
World(WithinHelpers)

Given /^(?:|I )am on (.+)$/ do |page_name|
  visit path_to(page_name)
end

When /^(?:|I )go to (.+)$/ do |page_name|
   visit path_to(page_name)
end

When /^(?:|I )show dropdown menus$/ do
  begin
    page.execute_script('jQuery("#app_toolbar > ul > li > ul").css("display", "block")')
  rescue Capybara::NotSupportedByDriverError
  end
end

When /^(?:|I )press "([^"]*)"(?: within "([^"]*)")?$/ do |button, selector|
  with_scope(selector) do
    click_button(button)
  end
end

When /^(?:|I )follow "([^"]*)"(?: within "([^"]*)")?$/ do |link, selector|
  with_scope(selector) do
    click_link(link)
  end
end

When /^(?:|I )fill in "([^"]*)" with "([^"]*)"(?: within "([^"]*)")?$/ do |field, value, selector|
  with_scope(selector) do
    fill_in(field, :with => value)
  end
end

When /^(?:|I )fill in "([^"]*)" for "([^"]*)"(?: within "([^"]*)")?$/ do |value, field, selector|
  with_scope(selector) do
    fill_in(field, :with => value)
  end
end

# Use this to fill in an entire form with data from a table. Example:
#
#   When I fill in the following:
#     | Account Number | 5002       |
#     | Expiry date    | 2009-11-01 |
#     | Note           | Nice guy   |
#     | Wants Email?   |            |
#
# TODO: Add support for checkbox, select og option
# based on naming conventions.
#
When /^(?:|I )fill in the following(?: within "([^"]*)")?:$/ do |selector, fields|
  with_scope(selector) do
    fields.rows_hash.each do |name, value|
      step %{I fill in "#{name}" with "#{value}"}
    end
  end
end

When /^(?:|I )select "([^"]*)" from "([^"]*)"(?: within "([^"]*)")?$/ do |value, field, selector|
  with_scope(selector) do
    select(value, :from => field)
  end
end

When /^(?:|I )unselect option "([^"]*)"(?: within "([^"]*)")?$/ do |value, selector|
  with_scope(selector) do
    page.execute_script("$('option').each(function(){if($(this).html() == '#{value}') $(this).removeAttr('selected')})") 
  end
end

When /^(?:|I )check "([^"]*)"(?: within "([^"]*)")?$/ do |field, selector|
  with_scope(selector) do
    check(field)
  end
end

# Use this step in conjunction with Rail's datetime_select helper. For example:
# When I select "December 25, 2008 10:00" as the date and time
When /^(?:|I )select "([^"]*)" as the date and time$/ do |time|
  select_datetime(time)
end

When /^(?:|I )uncheck "([^"]*)"(?: within "([^"]*)")?$/ do |field, selector|
  with_scope(selector) do
    uncheck(field)
  end
end

# Use this step in conjunction with Rail's time_select helper. For example:
# When I select "2:20PM" as the time
# Note: Rail's default time helper provides 24-hour time-- not 12 hour time. Webrat
# will convert the 2:20PM to 14:20 and then select it.
When /^(?:|I )select "([^"]*)" as the time$/ do |time|
  select_time(time)
end

When /^(?:|I )choose "([^"]*)"(?: within "([^"]*)")?$/ do |field, selector|
  with_scope(selector) do
    choose(field)
  end
end

# Use this step in conjunction with Rail's date_select helper.  For example:
# When I select "February 20, 1981" as the date
When /^(?:|I )select "([^"]*)" as the date$/ do |date|
  select_date(date)
end

# Adds support for validates_attachment_content_type. Without the mime-type getting
# passed to attach_file() you will get a "Photo file is not one of the allowed file types."
# error message
When /^(?:|I )attach the file "([^"]*)" to "([^"]*)"(?: within "([^"]*)")?$/ do |path, field, selector|
  with_scope(selector) do
    attach_file(field, File.join(Rails.root.to_s, path))
  end
end

Then /^(?:|I )should see JSON:$/ do |expected_json|
  require 'json'
  expected = JSON.pretty_generate([ JSON.parse(expected_json.raw[0][0]) ])
  actual   = JSON.pretty_generate([ JSON.parse(response.body) ])
  expected.should == actual
end

Then /^(?:|I )should see "([^"]*)"(?: within "([^"]*)")?$/ do |text, selector|
  if selector
    page.should have_selector(selector, :text => text)
  else
    page.should have_content(text)
  end
end

Then /^(?:|I )should see the following within "([^"]*)":$/ do |selector, table|
  table.raw.each { |row|
    row.each { |e|
      waiter do
        page.find(selector, :text => e)
      end.should_not be_nil
    }
  }
end

When /I fill in fcbk control with "([^"]*)"/ do |user|
  fill_in_fcbk_control(user, false)
end

When /I unselect "([^"]*)" from fcbk control/ do |user|
  remove_from_fcbk_control(user)
end

Then /^(?:|I )should see \/([^\/]*)\/(?: within "([^"]*)")?$/ do |regexp, selector|
  regexp = Regexp.new(regexp)
  with_scope(selector) do
    if page.respond_to? :should
      page.should have_xpath('//*', :text => regexp)
    else
      assert page.has_xpath?('//*', :text => regexp)
    end
  end
end

Then /^(?:|I )should not see "([^"]*)"(?: within "([^"]*)")?$/ do |text, selector|
  begin
    with_scope(selector) do
      page.should have_no_content(text)
    end
  rescue Capybara::ElementNotFound, Selenium::WebDriver::Error::StaleElementReferenceError => e
  end
end

Then /^(?:|I )should not see \/([^\/]*)\/(?: within "([^"]*)")?$/ do |regexp, selector|
  regexp = Regexp.new(regexp)
  with_scope(selector) do
    if page.respond_to? :should
      page.should have_no_xpath('//*', :text => regexp)
    else
      assert page.has_no_xpath?('//*', :text => regexp)
    end
  end
end

Then /^the "([^"]*)" field(?: within "([^"]*)")? should contain "([^"]*)"$/ do |field, selector, value|
  with_scope(selector) do
    field = find_field(field)
    field_value = (field.tag_name == 'textarea') ? field.text != "" ? field.text : field.value : field.value
    if field_value.respond_to? :should
      field_value.should =~ /#{value}/
    else
      assert_match(/#{value}/, field_value)
    end
  end
end

Then /^the "([^"]*)" field(?: within "([^"]*)")? should not contain "([^"]*)"$/ do |field, selector, value|
  with_scope(selector) do
    field = find_field(field)
    field_value = (field.tag_name == 'textarea') ? field.text != "" ? field.text : field.value : field.value
    if field_value.respond_to? :should_not
      field_value.should_not =~ /#{value}/
    else
      assert_no_match(/#{value}/, field_value)
    end
  end
end

Then /^the "([^"]*)" checkbox(?: within "([^"]*)")? should be checked$/ do |label, selector|
  with_scope(selector) do
    field_checked = find_field(label)['checked']
    if field_checked.respond_to? :should
      field_checked.should be_true
    else
      assert field_checked
    end
  end
end

Then /^the "([^"]*)" checkbox(?: within "([^"]*)")? should not be checked$/ do |label, selector|
  with_scope(selector) do
    field_checked = find_field(label)['checked']
    if field_checked.respond_to? :should
      field_checked.should be_false
    else
      assert !field_checked
    end
  end
end

Then /^(?:|I )should be on (.+)$/ do |page_name|
  current_path = URI.parse(current_url).path
  if current_path.respond_to? :should
    current_path.should == path_to(page_name)
  else
    assert_equal path_to(page_name), current_path
  end
end

Then /^(?:|I )should have the following query string:$/ do |expected_pairs|
  query = URI.parse(current_url).query
  actual_params = query ? CGI.parse(query) : {}
  expected_params = {}
  expected_pairs.rows_hash.each_pair{|k,v| expected_params[k] = v.split(',')}

  if actual_params.respond_to? :should
    actual_params.should == expected_params
  else
    assert_equal expected_params, actual_params
  end
end

Then /^show me the page$/ do
  save_and_open_page
end

Then /^I should see:$/ do |table|
  table.raw.each do |row|
    page.should have_content(row.join)
  end
end

Then /^I should not see:$/ do |table|
  table.raw.each do |row|
    page.should_not have_content(row.join)
  end
end

Then /^I should be redirected to (.+)$/ do |page_name|
  URI.parse(current_url).path.should == path_to(page_name)
end

Then /^I have loaded (.*) for "([^\"]*)"$/ do |page, title|
  URI.parse(current_url).path.should == path_to(page,title)
end

When /^I load (.*) for "([^\"]*)"$/ do |page, title|
  visit path_to(page, title)
end

When /^I attach the "([^\"]*)" file at "([^\"]*)" to "([^\"]*)"$/ do |mime, path, field|
  attach_file(field, path, mime)
end