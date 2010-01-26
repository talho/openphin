Given 'I have the forum named "$name"' do |name|
  Forum.create!(:name => name)
end

Given 'I have the topic "$topic_name" to forum "$forum_name"' do |topic_name,forum_name|
  forum = Forum.create!(:name => forum_name)
  topic = forum.topics.create!(:name => topic_name, :poster_id => @current_user.id, :forum_id => forum.id)
  forum.topics << topic
end

When 'I fill out the audience form with:' do |table|
  fill_in_audience_form table
end
