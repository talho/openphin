When /^I edit my password to "([^"]*)" and confirm with "([^"]*)"$/ do |password,confirm|
  When %Q{I fill in "Password" with "#{password}"}
  And %Q{I fill in "Confirm password" with "#{confirm}"}
  And %Q{I press "Apply Changes"}
end
