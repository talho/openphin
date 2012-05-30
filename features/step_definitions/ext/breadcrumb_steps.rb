Then /^I should have the "([^\"]*)" breadcrumb selected$/ do |breadcrumb_name|
  page.should have_css('.breadCrumbItem.selected', :text => breadcrumb_name)
end

Then /^I the "([^\"]*)" breadcrumb should be selected$/ do |breadcrumb_name|
  page.should have_css('.breadcrumb li', :text => breadcrumb_name, :count => 1)
end
