Given 'a channel named "$name"' do |name|
  Channel.find_by_name(name) || Factory(:channel, :name => name)
end

Given 'I created the channel "$name"' do |name|
  When 'I follow "New Channel"'
  And %Q|I fill in "Name" with "#{name}"|
  And 'I press "Create"'
  
  Then 'I should see "Successfully created the channel"'
  And %Q|I should see "#{name}"|
end

Given 'I have been added to the channel "$name"' do |name|
  channel = Given(%Q|a channel named "#{name}"|)
  channel.users << current_user
end

Given '"$user_name" has been added to the channel "$channel_name"' do |user_name, channel_name|
  user = Given(%Q|a user named #{user_name}|)
  channel = Given(%Q|a channel named "#{channel_name}"|)
  channel.users << user
end

Given 'a document "$document" is in the channel "$channel"' do |filename, channel|
  user = Given('a user in a non-public role')
  document = user.documents.create! :file => File.open(File.expand_path(RAILS_ROOT+'/spec/fixtures/'+filename))
  document.channels << Given(%Q|a channel named "#{channel}"|)
end


When 'I fill out the channel invitation form with:' do |table|
  fill_in_audience_form table
end
