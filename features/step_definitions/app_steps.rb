
Given /^"(.*?)" is the root jurisdiction of app "(.*?)"$/ do |jur, app|
  jur = step %Q{a jurisdiction named "#{jur}"}
  app = step %Q{an app named "#{app}"}
  app.root_jurisdiction = jur
  app.save!
end

Given /^an app named "([^"]*)"$/ do |app|
  App.where(name: app).first || FactoryGirl.create(:app, name: app)
end

Given /^"([^"]*)" is the default app$/ do |app|
  App.find_by_is_default(true).update_attributes is_default: false
  App.find_by_name(app).update_attributes is_default: true
end

When /^I create a new app$/ do
  step %Q{I click x-tab-strip-text "New App"}
  step %Q{I fill in "App Name" with "test"}
  step %Q{I fill in "Domains" with "test.com"}
  step %Q{I press "Save"}
  step %Q{I should see "App Details: test"}
end

Then /^my new app should exist$/ do
  app = App.find_by_name('test')
  app.should_not be_nil
  app.domains.should be_eql 'test.com'
end

When /^I edit app "(.*?)"$/ do |app|
  step %Q{I select the "#{app}" grid row}
end

When /^I fill in app details$/ do
  step %Q{I fill in the following:}, table(%{
    | Domains    | test.com, hi.com                                                                                                |
    | Help Email | admins@talho.org                                                                                                |
    | Login text | Lorem ipsum dolor sit amet, consectetur adipiscing elit.<br/>Phasellus mauris diam, aliquet nec scelerisque in. |
  })
  step %Q{I select "Texas" from ext combo "Root Jurisdiction"}
end

Then /^app "(.*?)" should have my new details$/ do |app|
  app = App.find_by_name(app)
  app.domains.should be_eql "test.com, hi.com"
  app.help_email.should be_eql "admins@talho.org"
  app.login_text.should be_eql "Lorem ipsum dolor sit amet, consectetur adipiscing elit.<br/>Phasellus mauris diam, aliquet nec scelerisque in."
  app.root_jurisdiction_id.should be_eql Jurisdiction.find_by_name("Texas").id
end

When /^I add some new assets$/ do
  step %Q{I click x-boot-pill "Assets"}
  step %Q{I attach the file "features/fixtures/keith.jpg" to "app[logo]"}
  step %Q{I attach the file "features/fixtures/keith.jpg" to "app[tiny_logo]"}
end

Then /^app "(.*?)" should have my assets$/ do |app|
  app = App.find_by_name(app)
  app.logo_file_name.should_not be_nil
  app.tiny_logo_file_name.should_not be_nil
end

When /^I fill in app about$/ do
  step %Q{I click x-boot-pill "About"}
  step %Q{I fill in "About Page Label" with "About TEST TEST TEST"}
  step %Q{I fill in "About Page HTML" with "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Integer accumsan, felis non aliquam lacinia, diam tellus scelerisque erat, ut accumsan dui leo eget dolor."}
  step %Q{I click x-form-item-label "About Page Label"} #force the box to lose focus.
end

Then /^app "(.*?)" should have my new about$/ do |app|
  app = App.find_by_name(app)
  app.about_label.should be_eql "About TEST TEST TEST"
  app.about_text.should be_eql "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Integer accumsan, felis non aliquam lacinia, diam tellus scelerisque erat, ut accumsan dui leo eget dolor."
end

Then /^I should see my new about$/ do
  step %Q{I go to the dashboard page} # refresh
  step %Q{I should see "About TEST TEST TEST"}
  step %Q{I navigate to "About TEST TEST TEST"}
  step %Q{I should see "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Integer accumsan, felis non aliquam lacinia, diam tellus scelerisque erat, ut accumsan dui leo eget dolor."}
end

When /^I add a role to the app$/ do
  step %Q{I click x-boot-pill "Roles"}
  step %Q{I press "New Role"}
  step %Q{I fill in "Name" with "Test Role"}
  step %Q{I fill in "Description" with "For a test of roles, silly"}
  step %Q{I check "User selectable"}
  step %Q{I check "Able to send alerts"}
  step %Q{I press "Save"}
  step %Q{I should not see "New Role" within ".x-window"}
end

Then /^app "(.*?)" should have my new role$/ do |app|
  step %Q{I should see "Test Role"}
  app = App.find_by_name(app)
  role = app.roles.find_by_name("Test Role")
  role.description.should be_eql "For a test of roles, silly"
  role.user_role.should be_true
  role.alerter.should be_true
  role.public.should be_false
end

When /^I edit role "(.*?)" for the app$/ do |role|
  step %Q{I click x-boot-pill "Roles"}
  step %Q{I click role-edit-icon on the "#{role}" grid row}
  step %Q{I fill in "Name" with "Content"}
  step %Q{I fill in "Description" with "Kittens!"}
  step %Q{I uncheck "User selectable"}
  step %Q{I press "Save"}
  step %Q{I should not see "Edit Role" within ".x-window"}
end

Then /^app "(.*?)" should have an updated role$/ do |app|
  app = App.find_by_name(app)
  role = app.roles.find_by_name("Content")
  role.description.should be_eql "Kittens!"
  role.user_role.should be_false
  role.alerter.should be_false
  role.public.should be_false
end

When /^I remove the role "(.*?)" for the app$/ do |role|
  step %Q{I click x-boot-pill "Roles"}
  step %Q{I click role-delete-icon on the "#{role}" grid row}
  step %Q{I press "Yes"}
end

Then /^app "(.*?)" should not have role "(.*?)"$/ do |app, role|
  app = App.find_by_name(app)
  app.roles.find_by_name(role).should be_nil
  Role.find_by_name(role).should be_nil # the role shouldn't even be in the system anymore
end

When /^I remove app "(.*?)"$/ do |app|
  #reload the manage apps tab
  step %Q{I close the active tab}
  step %Q{I navigate to "Admin > Manage Apps"}
  step %Q{I click app-delete-icon on the "#{app}" grid row}
  step %Q{I press "Yes"}
end

Then /^app "(.*?)" should not exist$/ do |app|
  App.find_by_name(app).should be_nil
end

Given /^microsoft and apple are apps$/ do
  step %Q{an app named "apple"}
  step %Q{an app named "microsoft"}
  step %Q{"California" is the root jurisdiction of app "apple"} 
  step %Q{"Washington" is the root jurisdiction of app "microsoft"} 
  step %Q{the following entities exist:}, table(%Q{
      | Role         | Turtleneck in Chief | apple     |
      | Role         | Zombie              | apple     |
      | Role         | Nerd Overlord       | microsoft |
      | Role         | Gamer               | microsoft |})
  step %Q{"Zombie" is a public role}
  step %Q{"Gamer" is a public role}
end

Then /^I should see the apple options$/ do
  step %Q{I go to the sign up page}
  step %Q{"Turtleneck in Chief" should be an option for select "Role"}
  step %Q{"Zombie" should not be an option for select "Role"}
  step %Q{"Gamer" should not be an option for select "Role"}
end

Given /^I have the app "([^"]*)"$/ do |app|
  current_user.role_memberships.create role_id: App.find_by_name(app).roles.find_by_public(true).id, jurisdiction_id: current_user.home_jurisdiction_id
end
