

When /^I (?:click|select) the following in the audience panel(?: within "([^"]*)")?:$/ do |selector, table|
  # table is a | name          | type         |  state    |
  #            | Dallas County | Jurisdiction |  Region 1 |

  jurisdictions = table.hashes.find_all{|hash| hash['type'] == 'Jurisdiction'}
  roles = table.hashes.find_all{|hash| hash['type'] == 'Role'}
  users = table.hashes.find_all{|hash| hash['type'] == 'User'}
  gos = table.hashes.find_all{|hash| hash['type'] == 'Group' || hash['type'] == 'Organization'}

  select_jurisdictions(jurisdictions) unless jurisdictions.count == 0
  select_roles(roles) unless roles.count == 0
  select_users(users, selector) unless users.count == 0
  select_groups(gos) unless gos.count == 0

end

def select_jurisdictions(jurisdictions)
  step %Q{I click x-accordion-hd "Jurisdictions"} # make sure we're on the jurisdiction tab
  states = jurisdictions.map{ |jurisdiction| jurisdiction['state'] }.compact.delete_if { |st| st.blank? }
  states.each { |state| expand_state(state) }
  select_checkbox_grid_row('.jurisdictions', jurisdictions)
end

def expand_state(state)
  page.find(:xpath, ".//*[(contains(concat(' ', @class, ' '),  ' ux-maximgb-tg-elbow-end-plus ') or contains(concat(' ', @class, ' '),  ' ux-maximgb-tg-elbow-plus ') )  and ../../div/text() = '#{state}']").click
end

def select_roles(roles)
  step %Q{I click x-accordion-hd "Roles"}
  sleep(0.25)
  select_checkbox_grid_row('.roles', roles)
end

def select_groups(groups)
  step %Q{I click x-accordion-hd "Groups/Organizations"}
  sleep(1) # for some reason, groups needs a sleep while the others didn't?'
  select_checkbox_grid_row('.groups', groups)
end

def select_checkbox_grid_row(selector, rows)
  row_section = page.find(selector)
  rows.each do |row|
    cb = row_section.find(:xpath, ".//*[contains(concat(' ', @class, ' '), ' x-grid3-row-checker ') and ../../..//div/text() = '#{row['name']}']")
    cb.click
  end

end

def select_users(users, selector = nil)
  step %Q{I click x-accordion-hd "Users"}
  users.each do |user|
    with_scope(selector) do
      step %Q{I fill in "User" with "#{user['name']}"}
    end
    #we need to wait for the search to complete and select an item in order to fire off the result
    begin
      with_scope(selector) do
        page.find(:xpath, '//img[contains(concat(" ", @class, " "), "x-form-arrow-trigger") and ../input[@name="User"]]').click # click the user drop down
      end
      step %Q{I click x-combo-list-item "#{user['name']} - #{user['email']}"}
    rescue Capybara::TimeoutError # it couldn't find the drop down. I'm not sure why this is having problems, but for some reason on the second go, the dropdown doesn't go automatically. Repeating code because we want to only try this once before failing
      with_scope(selector) do
        page.find(:xpath, '//img[contains(concat(" ", @class, " "), "x-form-arrow-trigger") and ../input[@name="User"]]').click
      end
      step %Q{I click x-combo-list-item "#{user['name']} - #{user['email']}"}
    end
  end
end

Then /^I should see the following audience breakdown:?$/ do |table|
  step %{I wait for the "loading" mask to go away}
  audiences = table.hashes.find_all{|hash| hash['type'] == 'Jurisdiction' || hash['type'] == 'User' || hash['type'] == 'Role' || hash['type'] == 'Group' || hash['type'] == 'Organization'}
  recipients = table.hashes.find_all{|hash| hash['type'] == 'Recipient'}
   
  audiences.each do |audience|
    if page.respond_to? :should
      page.should have_content(audience['name'])
    else
      assert page.has_content?(audience['name'])
    end
  end     

  recipients.each do |recipient|
    if page.respond_to? :should
      page.should have_content(recipient['name'])
    else
      assert page.has_content?(recipient['name'])
    end
  end
end

Then /^I should see the profile tab for "([^\"]*)"$/ do |email|
  user = User.find_by_email!(email)
  user_id = page.evaluate_script("window.Application.phin.tabPanel.getActiveTab().tab_config.user_id")
  user_id.should == user.id
end