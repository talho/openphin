When /^I prepare for user topic tests$/ do
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
    | Hank Hill       | hhill@example.com     | User | Dallas County  |
    | Steve McAwesome | sawesome@example.com  | User | Dallas County  |
  })
  step %Q{I am logged in as "admin@dallas.gov"}
  step %Q{I open a new forum}
  step %Q{I create forum with name "ILI Tracking" and with audience:}, table(%{
    | name          | type         |
    | Dallas County | Jurisdiction |
  })
  step %Q{I open a new forum}
  step %Q{I create forum with name "Resource Tracking" and with audience:}, table(%{
    | name  | type         |
    | Texas | Jurisdiction |
  })
  step %Q{I am logged in as "hhill@example.com"}
  step %Q{I navigate to "Forums"}
end

When /^I prepare a topic "([^\"]*)" with "([^\"]*)"$/ do |name, content|
  step %Q{I open forum "ILI Tracking"}
  step %Q{I create topic "#{name}" with content "#{content}"}
  step %Q{I wait for the "Loading..." mask to go away}
end

When /^I open forum "([^\"]*)"$/ do |forum_name|
  step %Q{I select the "#{forum_name}" grid row}
end

When /^I (?:(create)?|edit) topic "([^\"]*)" with content "([^\"]*)"$/ do |create, topic_name, content|
  if (create == "create")
    step %Q{I press "New Topic"}
  end
  step %Q{I fill in "Topic Name" with "#{topic_name}"}
  step %Q{I fill in "topic[content]" with "#{content}"}
  step %{I press "Save"}
  step %Q{I wait for the "Saving..." mask to go away}
end

When /^I view the topics in forum "([^\"]*)" as "([^\"]*)"$/ do |forum_name, user|
  step %Q{I am logged in as "#{user}"}
  step %Q{I navigate to "Forums"}
  step %{I open forum "#{forum_name}"}
  step %Q{I wait for the "Loading..." mask to go away}
end

When /^I reply to "([^\"]*)" with "([^\"]*)"$/ do |topic, reply|
  step %Q{I select the "#{topic}" grid row}
  step %Q{I press "Reply"}
  step %Q{I fill in "topic[comment_attributes][content]" with "#{reply}"}
  step %{I press "Save"}
  step %Q{I wait for the "Saving..." mask to go away}
end

When /^the reply "([^\"]*)" to "([^\"]*)" exists and is visible$/ do |reply, topic_name|
  topic = Topic.find_by_name(topic_name)
  assert_not_nil topic
  comment = topic.comments.find_by_content(reply)
  assert_not_nil comment
  #TODO: Check visible
end

When /^I check and edit topic "([^\"]*)" to "([^\"]*)" with "([^\"]*)"$/ do |old_topic_name, new_topic_name, new_content|
  step %Q{"#{old_topic_name}" has visible edit_topic icon}
  step %Q{I click edit_topic on the "#{old_topic_name}" grid row}
  step %Q{I edit topic "#{new_topic_name}" with content "#{new_content}"}
end

Then /^the correct actions are visible( for owner)? on row "([^\"]*)"$/ do |owner, name|
  if (owner)
    step %Q{"#{name}" has visible edit_topic icon}
  elsif
    step %Q{"#{name}" has no visible edit_topic icon}
  end
  step %Q{"#{name}" has no visible move_topic icon}
  step %Q{"#{name}" has no visible delete_topic icon}
  step %Q{I should not see "New Subforum" within "x-btn-text"}
end

Then /^the topic "([^\"]*)" with content "([^\"]*)" exists and( not)? is visible$/ do |topic_name, content, exist|
  topic = Topic.find_by_name(topic_name)  
  assert_not_nil topic
  if (exist)
    step %Q{I should not see "#{topic_name}"}
  else
    step %Q{I should see "#{topic_name}"}
  end
  #TODO: Check content visible
  topic.content.should  == content
end