When /^I edit my password to "([^"]*)" and confirm with "([^"]*)"$/ do |password,confirm|
  step %Q{I fill in "Password" with "#{password}"}
  step %Q{I fill in "Confirm password" with "#{confirm}"}
  step %Q{I press "Apply Changes"}
end
