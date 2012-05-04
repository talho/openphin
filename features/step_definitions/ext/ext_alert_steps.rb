
When /^I select the following alert audience:$/ do |table|
  step %{delayed jobs are processed}
  step %{I click breadCrumbItem "Recipients"}
  step %{I should see "Recipient Preview"}
  step %{I select the following in the audience panel:}, table
end

When /^I fill in the ext alert defaults$/ do
  step %{I fill in the following:}, table(%{
    | Title   | H1N1 SNS push packs to be delivered tomorrow |
    | Message | There is a Chicken pox outbreak in the area  |})
  step %{I select "" from ext combo "Jurisdiction"}
  step %{I check "E-mail"}
end

When /^I send the alert$/ do
  step %{I click breadCrumbItem "Preview"}
  step %{I should have the "Preview" breadcrumb selected}

  step %{I press "Send Alert"}
  step %{the "Alert Log and Reporting" tab should be open}
  step %{the "Send Alert" tab should not be open}
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
  begin
    page.find(:xpath, "//a[../../span[text() = '#{title}']]", :text => link).should be_nil
  rescue
    true
  end
end

When /^I should see "([^\"]*)" for user "([^\"]*)"$/ do |text, user|
  page.find(:xpath, "//tr[.//div[text() = '#{user}']]", :text => text).should_not be_nil
end

When /^I wait for the audience calculation to finish$/ do
  begin
    wait_until do (!page.find('.working-notice')) end
  rescue Capybara::ElementNotFound
    assert true
  end
end
