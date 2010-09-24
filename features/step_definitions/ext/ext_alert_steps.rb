
When /^I select the following alert audience:$/ do |table|
  When %{delayed jobs are processed}
  When %{I click breadCrumbItem "Audience"}
  When %{I select the following in the audience panel:}, table
end

When /^I fill in the ext alert defaults$/ do
  When %{I fill in the following:}, table(%{
    | Title   | H1N1 SNS push packs to be delivered tomorrow |
    | Message | There is a Chicken pox outbreak in the area  |})
  And %{I select "" from ext combo "Jurisdiction"}
  And %{I check "E-mail"}
end

When /^I send the alert$/ do
  And %{I click breadCrumbItem "Preview"}
  Then %{I should have the "Preview" breadcrumb selected}

  When %{I press "Send Alert"}
  Then %{the "Alert Log and Reporting" tab should be open}
  And %{the "Send Alert" tab should not be open}
end

When /^I click "([^"]*)" within alert "([^"]*)"$/ do |link, title|
  btn = page.find(:xpath, "//a[../../span[text() = '#{title}']]", :text => link)
  if btn.nil?
    sleep 1
    btn = page.find(:xpath, "//a[../../span[text() = '#{title}']]", :text => link)
  end
  btn.click
end

Then /^I should not see button "([^\"]*)" for alert "([^\"]*)"$/ do |link, title|
  page.find(:xpath, "//a[../../span[text() = '#{title}']]", :text => link).should be_nil
end