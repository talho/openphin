Given 'the report derived from recipe "$recipe" by the author with email "$email"' do |recipe, email|
  author = User.find_by_email(email)
  report_recipe = "#{recipe}"
  FactoryGirl.create(:report_report, :author => author, :recipe => report_recipe)
end

Given /^reports derived from the following recipes and authored by exist:$/ do |table|
  table.raw.each do |row|
    step %Q(the report derived from recipe "#{row[0]}" by the author with email "#{row[1]}")
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

When /^I generate "([^"]*)" report on "([^"]*)" (titled|named) "([^"]*)"$/ do |recipe, model, where, parameter|
  if where == 'titled'
    id = model.constantize.find_by_title(parameter).id
  else
    id = model.constantize.find_by_name(parameter).id
  end
  criteria = {:recipe=>recipe,:model=>model,:method=>:find_by_id,:params=>id}
  report = current_user.reports.create!(:recipe=>recipe,:criteria=>criteria,:incomplete=>true)
  Reporters::Reporter.new(:report_id=>report[:id]).perform
  @report = current_user.reports.find_by_id(id)
  raise unless @report && @report.rendering.path
end

When /^I generate "([^"]*)" report$/ do |recipe|
  report = current_user.reports.create!(:recipe=>recipe,:incomplete=>true)
  Reporters::Reporter.new(:report_id=>report.id).perform
  @report = current_user.reports.find_by_id(report.id)
  raise unless @report && @report.rendering.path
end

When /^I inspect the generated rendering$/ do
  @rendering = File.read(@report.rendering.path)
end

Then /^I should (not )?see "([^\"]*)" in the rendering$/ do |inversion, text|
  if inversion
    @rendering.should_not include(text)
  else
    @rendering.should include(text)
  end
end

When /^I inspect the generated pdf$/ do
  @pdf = WickedPdf.new.pdf_from_string(File.read(@report.rendering.path))
end

Then /^I should (not )?see "([^\"]*)" in the pdf$/ do |inversion, text|
  unless @pdf_text
    Tempfile.open('pdf') do |temp_pdf|
      temp_pdf << @pdf
      Tempfile.open(['txt','.html']) do |temp_txt|
        `pdftohtml -c -i -noframes #{temp_pdf.path} #{temp_txt.path}`
        @pdf_text = File.read(temp_txt.path)
      end
    end
  end
  if inversion
    @pdf_text.should_not include(text)
  else
    @pdf_text.should include(text)
  end
end

When /^I inspect the generated csv$/ do
  @csv = @report.to_csv
end

Then /^I should (not )?see "([^\"]*)" in the csv$/ do |inversion, text|
  if inversion
    @csv.should_not include(text)
  else
    @csv.should include(text)
  end
end



