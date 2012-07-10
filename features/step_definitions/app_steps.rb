
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
