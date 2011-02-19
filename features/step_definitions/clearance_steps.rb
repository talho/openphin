require 'dispatcher'

# General

Then /^I should see error messages$/ do
  # use Capybara then Webrat
  if respond_to?(:page)
    assert_match /error(s)? prohibited/m, page.body
  else
    assert_match /error(s)? prohibited/m, response.body
  end
end

# Database

Given /^no user exists with an email of "(.*)"$/ do |email|
  assert_nil User.find_by_email(email)
end

Given /^I signed up with "(.*)\/(.*)"$/ do |email, password|
  user = Factory :user,
    :email                 => email,
    :password              => password,
    :password_confirmation => password,
    :email_confirmed       => false
end

Given /^I am signed up and confirmed as "(.*)\/(.*)"$/ do |email, password|
  user = Factory :user,
    :email                 => email,
    :password              => password,
    :password_confirmation => password
end

# Session

Then /^I should be signed in$/ do
  Given %{I am on the homepage}
  Then %{I should see "Sign Out"}
end

Then /^I should be signed out$/ do
  Given %{I am on the homepage}
  Then %{I should see "Sign In to Your Account"}
end

When /^session is cleared$/ do
  Given %{I am on the homepage}
  Then %{I should see "Sign In to Your Account"}
end

# Emails

Then /^a confirmation message should be sent to "(.*)"$/ do |email|
  user = User.find_by_email(email)
  sent = ActionMailer::Base.deliveries.first
  assert_equal [user.email], sent.to
  assert_match /confirm/i, sent.subject
  assert !user.token.blank?
  assert_match /#{user.token}/, sent.body
end

When /^I follow the confirmation link sent to "(.*)"$/ do |email|
  user = User.find_by_email(email)
  visit new_user_confirmation_path(:user_id => user, :token => user.token)
end

Then /^a password reset message should be sent to "(.*)"$/ do |email|
  user = User.find_by_email(email)
  find_email(email, Cucumber::Ast::Table.new([
    ['subject', 'password'],
    ['body contains', user.token]
  ])).should_not be_nil
  assert !user.token.blank?
end

When /^I follow the password reset link sent to "(.*)"$/ do |email|
  user = User.find_by_email(email)
  visit edit_user_password_path(:user_id => user, :token => user.token)
end

When /^I follow the password reset link with a damaged token sent to "(.*)"$/ do |email|
  user = User.find_by_email(email)
  visit edit_user_password_path(:user_id => user, :token => user.token<<"*")
end


When /^I try to change the password of "(.*)" without token$/ do |email|
  user = User.find_by_email(email)
  visit edit_user_password_path(:user_id => user)
end

Then /^I should be forbidden$/ do
  assert_response :forbidden
end

# Actions

When /^I sign in( with "remember me")? as "(.*)\/(.*)"$/ do |remember, email, password|
  When %{I go to the sign in page}
  And %{I fill in "Email" with "#{email}"}
  And %{I fill in "Password" with "#{password}"}
  And %{I check "Remember me"} if remember
  And %{I press "Sign in"}
end

When /^I sign out$/ do
  visit '/sign_out'
  unset_current_user
end

When /^I request password reset link to be sent to "(.*)"$/ do |email|
  When %{I go to the password reset request page}
  And %{I fill in "Email address" with "#{email}"}
  And %{I press "Reset password"}
end

When /^I update my password with "(.*)\/(.*)"$/ do |password, confirmation|
  And %{I fill in "Choose password" with "#{password}"}
  And %{I fill in "Confirm password" with "#{confirmation}"}
  And %{I press "Save this password"}
end

When /^I return next time$/ do
  When %{I go to the homepage}
end

Then /^my session should stay active$/ do
  session = Capybara::Session.new(:selenium_with_firebug)
  session.visit("http://#{page.driver.rack_server.host}:#{page.driver.rack_server.port}")
  waiter do
    session.page.find "*", :text => "Sign Out"
  end.should_not be_nil
end

Capybara::Driver::Selenium.class_eval do
  class << self
    def switch_session_by_name(name)
      if @sessions_by_name.nil?
        @sessions_by_name = {:default => @driver}
      end

      if @sessions_by_name[name.to_sym].nil?
        @driver = nil
        @sessions_by_name[name.to_sym] = driver
      else
        @driver = @sessions_by_name[name.to_sym]
      end
    end

    def quit_session_by_name(name)
      @sessions_by_name[name.to_sym].quit
      @sessions_by_name.delete(name.to_sym)
    end

    def driver
      unless @driver
        profile = Selenium::WebDriver::Firefox::Profile.new
        profile['extensions.firebug.currentVersion'] = '100.100.100'
        profile['extensions.firebug.console.enableSites'] = 'true'
        profile['extensions.firebug.script.enableSites'] = 'true'
        profile['extensions.firebug.net.enableSites'] = 'true'
        profile.add_extension("#{Rails.root}/features/support/firebug.xpi") if File.exists?("#{Rails.root}/features/support/firebug.xpi")
        @driver = Selenium::WebDriver.for :firefox, :profile => profile
        at_exit do
          # Will receive an error if the default session closes before the other sessions
          if @sessions_by_name
            if @driver == @sessions_by_name[:default]
              @sessions_by_name.each do |key, thedriver|
                sleep 1
                unless key == :default
                  thedriver.quit
                end
              end
              @sessions_by_name[:default].quit
              @sessions_by_name = {}
            else
              if index = @sessions_by_name.index(@driver)
                @sessions_by_name.delete(index)
                @driver.quit
              end
            end
          else
            @driver.quit
          end
        end
      end
      @driver
    end
  end
end

Given /^session name is "([^\"]*)"$/ do |name|
  Capybara::Driver::Selenium.switch_session_by_name(name)
end

Given /^quit session name "([^\"]*)"$/ do |name|
  Capybara::Driver::Selenium.quit_session_by_name(name)
end
