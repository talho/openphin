

When /^I select the following in the audience panel:$/ do |table|
  # table is a | Dallas County | Jurisdiction |
  jurisdictions = table.hashes.find_all{|hash| hash['type'] == 'Jurisdiction'}
  roles = table.hashes.find_all{|hash| hash['type'] == 'Role'}
  users = table.hashes.find_all{|hash| hash['type'] == 'User'}

  select_jurisdictions(jurisdictions) unless jurisdictions.count == 0
  select_roles(roles) unless roles.count == 0
  select_users(users) unless users.count == 0
end

def select_jurisdictions(jurisdictions)
  When %Q{I click x-accordion-hd "Jurisdictions"} # make sure we're on the jurisdiction tab
  select_checkbox_grid_row('.jurisdictions', jurisdictions)
end

def select_roles(roles)
  When %Q{I click x-accordion-hd "Roles"}
  select_checkbox_grid_row('.roles', roles)
end

def select_checkbox_grid_row(selector, rows)
  row_section = page.find(selector)
  rows.each do |row|
    cb = row_section.find(:xpath, ".//*[contains(concat(' ', @class, ' '), ' x-grid3-row-checker ') and ../../..//div/text() = '#{row['name']}']")
    cb.click
  end

end

def select_users(users)
  When %Q{I click x-accordion-hd "Users"}
end

Then /^I should see the following audience breakdown$/ do |table|
  audiences = table.hashes.find_all{|hash| hash['type'] == 'Jurisdiction' || hash['type'] == 'User' || hash['type'] == 'Role'}
  recipients = table.hashes.find_all{|hash| hash['type'] == 'Recipient'}
   
  with_scope('.audiences') do
    audiences.each do |audience|
      if page.respond_to? :should
        page.should have_content(audience['name'])
      else
        assert page.has_content?(audience['name'])
      end
    end
  end     

  with_scope('.recipients') do
    recipients.each do |recipient|
      if page.respond_to? :should
        page.should have_content(recipient['name'])
      else
        assert page.has_content?(recipient['name'])
      end
    end
  end
end

Then /^I should see the profile tab for "([^\"]*)"$/ do |email|
  user = User.find_by_email!(email)
  tab_url = page.evaluate_script("window.Application.phin.tabPanel.getActiveTab().url")
  URI.parse(tab_url).path.should == user_profile_path(user)
end

When /^I click ([a-zA-Z0-9\-]*) on the "([^\"]*)" grid row(?: within "([^"]*)")?$/ do |selector, content, within_selector|
  # we want to find the row with the content, and get the div that's a few levels up
  with_scope(within_selector) do
    row = page.find(:xpath, "//div[contains(concat(' ', @class, ' '), 'x-grid3-row') and .//text() = '#{content}']")
    row.find(:xpath, ".//*[contains(concat(' ', @class, ' '), '#{selector}')]").click
  end
end