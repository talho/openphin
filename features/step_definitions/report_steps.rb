Given 'the report derived from recipe "$recipe" by the author with email "$email"' do |recipe, email|
  author = User.find_by_email(email)
  report_recipe = "#{recipe}"
  FactoryGirl.create(:report_report, :author => author, :recipe => report_recipe)
end

Given /^reports derived from the following recipes and authored by exist:$/ do |table|
  table.raw.each do |row|
    Given %Q(the report derived from recipe "#{row[0]}" by the author with email "#{row[1]}")
  end
end

When 'the system registers the report recipes' do
#  "Report::Recipe".constantize.register_recipes
end

Given 'the system builds all the user roles' do
  require File.expand_path(File.join(File.dirname(__FILE__),"..","..","db","fixtures","roles"))
end

Given 'the system builds all the user jurisdictions' do
  require File.expand_path(File.join(File.dirname(__FILE__),"..","..","db","fixtures","jurisdictions"))
end

