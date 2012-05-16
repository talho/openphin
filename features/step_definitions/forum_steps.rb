When /^I open a new forum$/ do
  step %Q{I navigate to "Forums"}
  step %Q{I press "New Forum"}
  step %Q{I should see the "New Forum" panel}
end

When /^I edit forum "([^\"]*)"$/ do |forum_name|
  step %Q{I navigate to "Forums"}
  step %Q{the forum "#{forum_name}" exists and is visible}
  step %Q{the "#{forum_name}" grid row should have the edit_forum icon}
  step %Q{I click edit_forum on the "#{forum_name}" grid row}
  step %Q{I should see the "Edit Forum" panel}
end

When /^I manage forum "([^\"]*)"$/ do |forum_name|
  step %Q{I navigate to "Forums"}
  step %Q{the forum "#{forum_name}" exists and is visible}
  step %Q{the "#{forum_name}" grid row should have the manage_forum icon}
  step %Q{I click manage_forum on the "#{forum_name}" grid row}
  step %Q{I should see the "Manage Moderators" panel}
  step %Q{I should see the following audience breakdown:}, table(%{
    | name | type |
  })
end

When /^I prepare for admin forum tests$/ do
  step %Q{the following entities exists:}, table(%{
    | Jurisdiction  | Texas                   |
    | Jurisdiction  | Dallas County           |
    | Role          | Animal Control Director |
    | Role          | Chief Epidemiologist    |
  })
  step %Q{Federal is the parent jurisdiction of:}, table(%{
    | Texas |
  })
  step %Q{Texas is the parent jurisdiction of:}, table(%{
    | Dallas County |
  })
  step %Q{the following administrators exist:}, table(%{
    | admin@dallas.gov | Dallas County |
  })
  step %Q{I am logged in as "admin@dallas.gov"}
end

When /^I prepare for (user|moderator)? forum tests$/ do |mode|
  step %Q{the following entities exists:}, table(%{
    | Jurisdiction  | Texas                   |
    | Jurisdiction  | Dallas County           |
    | Role          | Animal Control Director |
    | Role          | Chief Epidemiologist    |
  })
  step %Q{Federal is the parent jurisdiction of:}, table(%{
    | Texas |
  })
  step %Q{Texas is the parent jurisdiction of:}, table(%{
    | Dallas County |
  })
  step %Q{the following administrators exist:}, table(%{
    | admin@dallas.gov | Dallas County |
  })  
  step %Q{the following users exist:}, table(%{
    | Hank Hill | hhill@example.com | User | Dallas County |
  })
  step %Q{I am logged in as "admin@dallas.gov"}
  step %Q{I open a new forum} 
  step %Q{I create forum with name "ILI Tracking" and with audience:}, table(%{
    | name          | type         |
    | Dallas County | Jurisdiction |
  })
  if (mode == "moderator")
    step %Q{I click manage_forum on the "ILI Tracking" grid row}
    step %Q{I select the following in the audience panel:}, table(%Q{
      | name                 | type         |
      | Dallas County        | Jurisdiction |
    })    
    step %Q{I press "Save"}
  end
  step %Q{I open a new forum}
  step %Q{I create forum with name "Resource Discovery" and with audience:}, table(%{
    | name          | type         |
  })
  step %Q{I am logged in as "hhill@example.com"}
  step %Q{I navigate to "Forums"}
end

When /^I enter the new forum data and save$/ do
  step %Q{I create forum with name "Dallas Region Discussion" and with audience:}, table(%{
      | name  | type         |
      | Texas | Jurisdiction |
  })
end

When /^I enter the edit forum data and save$/ do
  step %Q{I edit forum with name "Dallas Discussion" and with audience:}, table(%{
      | name                    | type |
      | Animal Control Director | Role |
  })
end

When /^I manage the forum and save$/ do
  step %Q{I select the following in the audience panel:}, table(%Q{
    | name                 | type |
    | Chief Epidemiologist | Role |
  })
  step %Q{I press "Save"}
end

When /^I enter the new hidden forum data and save$/ do
  step %Q{I create hidden forum with name "Hidden Discussion" and with audience:}, table(%{
    | name          | type          |
    | Dallas County | Jurisdiction  |
  })
  step %Q{I wait for the "Saving..." mask to go away}
end

Then /^I should see the "([^\"]*)" panel$/ do |name|
  step %Q{I the "#{name}" breadcrumb should be selected}
end

Then /^the management of the forum is verified$/ do
  step %Q{the forum "Dallas Discussion" exists and is visible}
  #TODO: verify the moderatorness
end

Then /^the hidden forum is verified$/ do
  step %Q{the forum "Hidden Discussion" exists and is visible}
  forum = Forum.find_by_name("Hidden Discussion")
  assert_not_nil forum.hidden_at
  step %Q{I edit forum "Hidden Discussion"}
  page.should have_css('input[checked]')
  #TODO: verify that a regular user can't see the hidden forum
  #TODO: verify that a administrator and not owner can see it
  #TODO: verify that it has a hidden forum icon
end

When /^I (?:create|edit)( hidden)? forum with name "([^\"]*)" and with audience:$/ do |hidden, forum_name, table|  
  step %Q{I select the following in the audience panel:}, table
  step %Q{I fill in "Forum Name" with "#{forum_name}"}
  step %Q{I check "Hidden"} if hidden
  step %Q{I press "Save"}
end

When /^"([^\"]*)" has( no)? visible ([^\"]*) icon$/ do |name, visible, icon_name|  
  row = page.find(".x-grid3-row", :text => name)
  row.should have_css("img.#{icon_name}" + (visible ? ".x-hide-display" : ""))
end

Then /^the forum "([^\"]*)" exists and is( not)? visible$/ do |forum_name, exist|
  forum = Forum.find_by_name(forum_name)
  #TODO: nav to forums index
  if (exist)
    step %Q{I should not see "#{forum_name}"}
  else
    step %Q{I should see "#{forum_name}"}
  end
end

Given /^I have the forum "([^\"]*)"$/ do |forum_name|
  if forum = Forum.find_by_name(forum_name)
    forum
  else
    forum = FactoryGirl.create(:forum, :name => forum_name, :owner_id => current_user.id)
    forum
  end
end
