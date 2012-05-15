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
  step %Q{the forum "Dallas Discussion" exists and is visible}
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
end

When /^I (?:create|edit)( hidden)? forum with name "([^\"]*)" and with audience:$/ do |hidden, forum_name, table|  
  step %Q{I select the following in the audience panel:}, table
  step %Q{I fill in "Forum Name" with "#{forum_name}"}
  step %Q{I check "Hidden"} if hidden
  step %Q{I press "Save"}
end

Then /^the forum "([^\"]*)" exists and is visible$/ do |forum_name|
  forum = Forum.find_by_name(forum_name)
  #TODO: nav to forums index
  step %Q{I should see "#{forum_name}"}
end

Given /^I have the forum "([^\"]*)"$/ do |forum_name|
  if forum = Forum.find_by_name(forum_name)
    forum
  else
    forum = FactoryGirl.create(:forum, :name => forum_name, :owner_id => current_user.id)
    forum
  end
end
# Given 'I have the forum named "$name"' do |name|
  # Forum.find_by_name(name) || FactoryGirl.create(:forum, :name => name)
# end
# 
# Given 'I have the topic "$topic_name" to forum "$forum_name"' do |topic_name,forum_name|
  # forum = Forum.find_by_name(forum_name) || FactoryGirl.create(:forum, :name => forum_name)
  # topic = Topic.find_by_name(topic_name) || FactoryGirl.create(:topic, :name => topic_name, :forum => forum, :poster => current_user)
# end
# 
# Given 'I have the comment "$comment_content" to topic "$topic_name" to forum "$forum_name"' do |comment_content,topic_name,forum_name|
  # forum = Forum.find_by_name(forum_name) || FactoryGirl.create(:forum, :name => forum_name)
  # topic = Topic.find_by_name(topic_name) || FactoryGirl.create(:topic, :name => topic_name, :forum => forum, :poster => current_user)
  # comment = Topic.find_by_content(comment_content) || FactoryGirl.create(:comment, :name => "not blank", :content => comment_content, :poster => @current_user, :forum => forum, :poster => current_user)
  # topic.comments << comment
# end
# 
# Given 'the forum "$forum_name" has the following audience:' do |forum_name, table|
  # forum = Forum.find_by_name!(forum_name)
  # table.raw.each do |row|
    # case row[0]
    # when "Jurisdictions"
      # row[1].split(",").each do |name|
        # jurisdiction = Jurisdiction.find_by_name!(name.strip)
        # forum.jurisdictions << jurisdiction
      # end
    # when "Roles"
      # row[1].split(",").each do |name|
        # role = Role.find_by_name!(name.strip)
        # forum.audience.roles << role
      # end
    # when "Users"
      # row[1].split(",").each do |email|
        # user = User.find_by_email!(email.strip)
        # forum.audience.users << user
      # end
    # end
  # end
# end
# 
# When 'I fill out the audience form with:' do |table|
  # fill_in_audience_form table
# end

