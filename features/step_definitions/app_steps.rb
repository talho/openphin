
Given /^"(.*?)" is the root jurisdiction of app "(.*?)"$/ do |jur, app|
  jur = step %Q{a jurisdiction named "#{jur}"}
  app = step %Q{an app named "#{app}"}
  app.root_jurisdiction = jur
  app.save!
end

Given /an app named "(.*?)"/ do |app|
  App.where(name: app).first || FactoryGirl.create(:app, name: app)
end
