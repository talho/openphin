Given 'the report derived from recipe "$recipe" by the author with email "$email"' do |recipe, email|
  author = User.find_by_email(email)
  type = "Report::#{recipe}"
  recipe = Report::Recipe.find_by_type(type) || Factory(:report_recipe, :type => type)
  Factory(:report_report, :author => author, :recipe => recipe)
end

Given /^the following reports exist:$/ do |table|
  table.raw.each do |row|
    Given %Q(the report derived from recipe "#{row[0]}" by the author with email "#{row[1]}")
  end
end
