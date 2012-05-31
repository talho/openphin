When /^I prepare for topic tests$/ do
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
    | Mr Moderator    | moderator@example.com | User | Dallas County  |
  })  
  admin = User.find_by_email("admin@dallas.gov")
  FactoryGirl.create(:forum, :name => 'ILI Tracking', :owner_id => admin.id, 
    :audience_attributes => { :jurisdiction_ids => [Jurisdiction.find_by_name('Dallas County').id]}, 
    :moderator_audience_attributes => { :user_ids => [User.find_by_email('moderator@example.com').id]})
  forum = FactoryGirl.create(:forum, :name => 'Resource Tracking', :owner_id => admin.id, :audience_attributes => { :jurisdiction_ids => [Jurisdiction.find_by_name('Texas').id]} )
  # step %Q{I am logged in as "admin@dallas.gov"}
  # step %Q{I open a new forum}
  # step %Q{I create forum with name "ILI Tracking" and with audience:}, table(%{
    # | name          | type         |
    # | Dallas County | Jurisdiction |
  # })
  # step %Q{I open a new forum}
  # step %Q{I create forum with name "Resource Tracking" and with audience:}, table(%{
    # | name  | type         |
    # | Texas | Jurisdiction |
  # })  
end

When /^I prepare for user topic tests$/ do
  step %Q{I prepare for topic tests}
  step %Q{I am logged in as "hhill@example.com"}
  step %Q{I navigate to "Forums"}
end

When /^I prepare for admin topic tests$/ do 
  step %Q{I prepare for topic tests}
  # sleep 0.2
  # step %Q{I am logged in as "admin@dallas.gov"}
  # step %Q{I navigate to "Forums"}
  # step %Q{I click ".forum-manage[forum_name='ILI Tracking']"}
  # step %Q{I select the following in the audience panel:}, table(%Q{
    # | name         | type |
    # | Mr Moderator | User |
  # })
  # step %Q{I press "Save"}
  step %Q{I am logged in as "admin@dallas.gov"}
  step %Q{I navigate to "Forums"}
end

When /^I prepare for moderator topic tests$/ do
  step %Q{I prepare for topic tests}  
  # sleep 0.2
  # step %Q{I am logged in as "admin@dallas.gov"}
  # step %Q{I navigate to "Forums"}
  # step %Q{I click ".forum-manage[forum_name='ILI Tracking']"} 
  # step %Q{I select the following in the audience panel:}, table(%Q{
    # | name         | type |
    # | Mr Moderator | User |
  # })
  # step %Q{I press "Save"}
  # sleep 0.2 
  step %Q{I am logged in as "moderator@example.com"}
  step %Q{I navigate to "Forums"}
end

When /^I prepare a topic "([^\"]*)" with "([^\"]*)"$/ do |name, content|  
  step %Q{I create topic "#{name}" with content "#{content}"}
  step %Q{I wait for the "Loading..." mask to go away}
end

When /^I open forum "([^\"]*)"$/ do |forum_name|
  sleep 0.2
  step %Q{I click ".forum-title[forum_name='#{forum_name}']"}
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
  step %Q{I click ".forum-topic-title[topic_name='#{topic}']"}
  step %Q{I press "Reply"}
  step %Q{I fill in "topic[comment_attributes][content]" with "#{reply}"}
  step %{I press "Save"}
  step %Q{I wait for the "Saving..." mask to go away}
end

When /^I edit comment "([^\"]*)" to "([^\"]*)" in topic "([^\"]*)"$/ do |old_comment, new_comment, topic|
  sleep 0.2 
  step %Q{I click ".forum-comment-edit[topic_name='#{old_comment}']"}
  step %Q{I fill in "topic[comment_attributes][content]" with "#{new_comment}"}
  step %Q{I press "Save"}
  step %Q{I wait for the "Saving..." mask to go away}
end

When /^I quote "([^\"]*)" adding "([^\"]*)" in topic "([^\"]*)"$/ do |quote, comment, topic|  
  step %Q{I click ".forum-comment-quote[topic_name='#{quote}']"}
  comment = field = find_field("topic[comment_attributes][content]").value + comment
  step %Q{I fill in "topic[comment_attributes][content]" with "#{comment}"}
  step %{I press "Save"}
  step %Q{I wait for the "Saving..." mask to go away}
end

Then /^the reply "([^\"]*)" to "([^\"]*)" exists and is visible$/ do |reply, topic_name|
  topic = Topic.where("comment_id is null and name = '#{topic_name}'").first
  assert_not_nil topic  
  comment = Topic.where("comment_id = #{topic.id} and content = '#{reply}'")
  assert_not_nil comment  
end

When /^the quote "([^\"]*)" from "([^\"]*)" to "([^\"]*)" exists and is visible$/ do |quote, comment, topic_name|
  topic = Topic.find_by_name(topic_name)
  assert_not_nil topic
  lookup = "select * from topics where content like '%" + comment + "%" + quote + "%'"
  comment = Topic.find_by_sql(lookup)
  assert_not_nil comment
end

When /^I move "([^\"]*)" to "([^\"]*)"$/ do |topic, newForum|
  step %Q{I click ".forum-topic-move[topic_name='#{topic}']"} 
  step %Q{I select "#{newForum}" from ext combo "forumMover"}
  step %Q{I press "Save"}  
  step %Q{I wait for the "Saving..." mask to go away}
end

When /^I delete "([^\"]*)" from topic "([^\"]*)"$/ do |comment, topic|
  step %Q{I click ".forum-topic-title[topic_name='#{topic}']"}  
  step %Q{I click ".forum-comment-delete[topic_name='#{comment}']"} 
  step %Q{I press "Yes"}
end

When /^I delete comment "([^\"]*)"$/ do |comment|
  step %Q{I click ".forum-comment-delete[topic_name='#{comment}']"} 
  step %Q{I press "Yes"}
end

When /^I( don't)? delete topic "([^\"]*)"$/ do |cancel, topic|
  sleep 0.5
  step %Q{I click ".forum-topic-delete[topic_name='#{topic}']"} 
  if cancel
    step %Q{I press "No"}
  else
    step %Q{I press "Yes"}
  end
end

When /^I (Sticky|Locked)? "([^\"]*)"$/ do |action, topic|
  step %Q{I click ".forum-topic-edit[topic_name='#{topic}']"} 
  step %Q{I check "#{action}"}
  step %Q{I press "Save"}
  step %Q{I wait for the "Saving..." mask to go away}
  step %Q{I wait for the "Loading..." mask to go away}
end


When /^I check and edit topic "([^\"]*)" to "([^\"]*)" with "([^\"]*)"$/ do |old_topic_name, new_topic_name, new_content|
  step %Q{I click ".forum-topic-edit[topic_name='#{old_topic_name}']"} 
  step %Q{I edit topic "#{new_topic_name}" with content "#{new_content}"}
end

Then /^moderators and admins can post users can not$/ do  
  page.find(".forum-topic-title[topic_name='Resource Discovery'] img[src='/assets/resources/images/default/grid/hmenu-lock.png']")
  step %Q{I view the topics in forum "ILI Tracking" as "admin@dallas.gov"}
  step %Q{I reply to "Resource Discovery" with "Woo"}
  step %Q{the reply "Woo" to "Resource Discovery" exists and is visible}
  step %Q{I view the topics in forum "ILI Tracking" as "moderator@example.com"}
  step %Q{I reply to "Resource Discovery" with "Moderator Woo"} 
  step %Q{the reply "Moderator Woo" to "Resource Discovery" exists and is visible}
  step %Q{I view the topics in forum "ILI Tracking" as "hhill@example.com"}
  step %Q{I click ".forum-topic-title[topic_name='Resource Discovery']"}  
  step %Q{I should not see "Reply" within ".x-btn-text"}
end

Then /^the correct actions are visible( for owner)? on row "([^\"]*)"$/ do |owner, name|  
  if (owner)
    page.find(".forum-topic-edit[topic_name='#{name}']")
  elsif
    page.should have_no_css(".forum-topic-edit[topic_name='#{name}']")
  end
  page.should have_no_css(".forum-topic-move[topic_name='#{name}']")
  page.should have_no_css(".forum-topic-delete[topic_name='#{name}']")
  step %Q{I should not see "New Subforum" within ".x-btn-text"}
end

Then /^I should see the topics in this order "([^\"]*)"$/ do |orders|
  orders = orders.split
  orders.each do |order|
    cmp = order.split(">")
    step %{I should see "#{cmp[0]}" within ".forum-topic-row-#{cmp[1]} .forum-topic-title[topic_name='#{cmp[0]}']"}
  end
end

Then /^the topic "([^\"]*)" with content "([^\"]*)" exists and( not)? is visible$/ do |topic_name, content, exist|
  topic = Topic.where("comment_id is null and name = '#{topic_name}' and content = '#{content}'")
  assert_not_nil topic
  if (exist)
    step %Q{I should not see "#{topic_name}"}
  else
    step %Q{I should see "#{topic_name}"}
  end  
end

Then /^the topic "([^\"]*)" doesn't exist and is not visible$/ do |topic_name|
  topic = Topic.find_by_name(topic_name)
  assert_nil topic
  step %Q{I should not see "#{topic_name}"}
end

Then /^the reply "([^\"]*)" to "([^\"]*)" doesn't exist and is not visible$/ do |reply, topic_name|
  topic = Topic.find_by_name(topic_name)
  assert_not_nil topic
  comment = topic.comments.find_by_content(reply)
  assert_nil comment
end 