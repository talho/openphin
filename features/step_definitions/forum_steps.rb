When /^I open a new forum$/ do
  step %Q{I navigate to "Forums"}
  step %Q{I press "New Forum"}
  step %Q{I should see the "New Forum" panel}
end

When /^I edit forum "([^\"]*)"$/ do |forum_name|
  step %Q{I navigate to "Forums"}
  step %Q{the forum "#{forum_name}" exists and is visible}  
  step %Q{I should have ".forum-edit[forum_name='#{forum_name}']" within "td"}
  step %Q{I click ".forum-edit[forum_name='#{forum_name}']"}
  step %Q{I should see the "Edit Forum" panel}
end

When /^I manage forum "([^\"]*)"$/ do |forum_name|
  step %Q{I navigate to "Forums"}
  step %Q{the forum "#{forum_name}" exists and is visible}
  step %Q{I should have ".forum-manage[forum_name='#{forum_name}']" within "td"}
  step %Q{I click ".forum-manage[forum_name='#{forum_name}']"}
  step %Q{I should see the "Manage Moderators" panel}
  step %Q{I should see the following audience breakdown:}, table(%{
    | name | type |
  })
end

When /^I prepare for new tab tests$/ do
   step %Q{I prepare for admin topic tests}
   step %Q{I open forum "ILI Tracking"}
   step %Q{I prepare a topic "Tracking" with "Let's find something"}
   step %{I click ".forum-topic-title[topic_name='Tracking']"}
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
    step %Q{I click ".forum-manage[forum_name='ILI Tracking']"}
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

Given /^I have the forum named "([^\"]*)"$/ do |name|
  Forum.find_by_name(name) || FactoryGirl.create(:forum, :name => name)
end

Given /^I have the topic "([^\"]*)" to forum "([^\"]*)"$/ do |topic_name,forum_name|
  forum = Forum.find_by_name(forum_name) || FactoryGirl.create(:forum, :name => forum_name)
  topic = Topic.find_by_name(topic_name) || FactoryGirl.create(:topic, :name => topic_name, :forum => forum, :poster => current_user)
end

When /^I have the comment "([^\"]*)" to topic "([^\"]*)" to forum "([^\"]*)"$/ do |comment_content, topic_name, forum_name|
  forum = FactoryGirl.create(:forum, :name => forum_name)
  topic = FactoryGirl.create(:topic, :name => topic_name, :poster => current_user, :forum => forum)
  comment = FactoryGirl.create(:comment, :name => "not blank", :content => comment_content, :forum => forum, :poster => current_user)
  topic.comments << comment
end

Then /^the management of the forum is verified$/ do
  step %Q{the forum "Dallas Discussion" exists and is visible}  
end

Then /^the hidden forum is verified$/ do
  step %Q{the forum "Hidden Discussion" exists and is visible}
  forum = Forum.find_by_name("Hidden Discussion")
  assert_not_nil forum.hidden_at
  step %Q{I edit forum "Hidden Discussion"}
  page.should have_css('input[checked]')
end

When /^I (?:create|edit)( hidden)? forum with name "([^\"]*)" and with audience:$/ do |hidden, forum_name, table|  
  step %Q{I select the following in the audience panel:}, table
  step %Q{I fill in "Forum Name" with "#{forum_name}"}
  step %Q{I check "Hidden"} if hidden
  step %Q{I press "Save"}
end

When /^I create a new tab$/ do
  step %Q{I press "New Tab"}
end

Then /^I see two forums tabs$/ do
  step %Q{the "Forums" tab should be open inactive}
  step %Q{the "Forums Tab" tab should be open active}
end

Then /^the forum "([^\"]*)" exists and is( not)? visible$/ do |forum_name, exist|
  forum = Forum.find_by_name(forum_name)
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
