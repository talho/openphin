Given 'I have the forum named "$name"' do |name|
  Forum.create!(:name => name)
end

Given 'I have the topic "$topic_name" to forum "$forum_name"' do |topic_name,forum_name|
  forum = Forum.create!(:name => forum_name)
  topic = forum.topics.create!(:name => topic_name, :poster_id => @current_user.id)
end

Given 'I have the comment "$comment_content" to topic "$topic_name" to forum "$forum_name"' do |comment_content,topic_name,forum_name|
  forum = Forum.create!(:name => forum_name)
  topic = forum.topics.create!(:name => topic_name, :poster_id => @current_user.id)
  comment = topic.comments.create!(:content => comment_content, :poster_id => @current_user.id, :name => "not blank",:forum_id => forum.id)
end

When 'I fill out the audience form with:' do |table|
  fill_in_audience_form table
end
