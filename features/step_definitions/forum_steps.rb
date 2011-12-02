Given 'I have the forum named "$name"' do |name|
  Forum.find_by_name(name) || Factory(:forum, :name => name)
end

Given 'I have the topic "$topic_name" to forum "$forum_name"' do |topic_name,forum_name|
  forum = Forum.find_by_name(forum_name) || Factory(:forum, :name => forum_name)
  topic = Topic.find_by_name(topic_name) || Factory(:topic, :name => topic_name, :forum => forum, :poster => current_user)
end

Given 'I have the comment "$comment_content" to topic "$topic_name" to forum "$forum_name"' do |comment_content,topic_name,forum_name|
  forum = Forum.find_by_name(name) || Factory(:forum, :name => forum_name)
  topic = Topic.find_by_name(name) || Factory(:topic, :name => topic_name, :forum => forum, :poster => current_user)
  comment = Topic.find_by_name(name) || Factory(:comment, :name => "not blank", :content => comment_content, :poster => @current_user, :forum => forum, :poster => current_user)
  topic.comments << comment
end

Given 'the forum "$forum_name" has the following audience:' do |forum_name, table|
  forum = Forum.find_by_name!(forum_name)
  table.raw.each do |row|
    case row[0]
    when "Jurisdictions"
      row[1].split(",").each do |name|
        jurisdiction = Jurisdiction.find_by_name!(name.strip)
        forum.jurisdictions << jurisdiction
      end
    when "Roles"
      row[1].split(",").each do |name|
        role = Role.find_by_name!(name.strip)
        forum.audience.roles << role
      end
    when "Users"
      row[1].split(",").each do |email|
        user = User.find_by_email!(email.strip)
        forum.audience.users << user
      end
    end
  end
end

When 'I fill out the audience form with:' do |table|
  fill_in_audience_form table
end
