Then /^I should have the "([^\"]*)" breadcrumb selected$/ do |breadcrumb_name|
  page.should have_css('.breadCrumbItem.selected', :text => breadcrumb_name)
end