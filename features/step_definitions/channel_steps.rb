Given 'a share named "$name"' do |name|
  Channel.find_by_name(name) || Factory(:channel, :name => name)
end

Given 'I created the share "$name"' do |name|
  When 'I follow "New Share"'
  And %Q|I fill in "Name" with "#{name}"|
  And 'I press "Create"'
  
  Then 'I should see "Successfully created the share"'
  And %Q|I should see "#{name}"|
end

Given 'I have been added to the share "$name"' do |name|
  channel = Given(%Q|a share named "#{name}"|)
  channel.users << current_user
end

Given '"$user_name" has been added to the share "$channel_name"' do |user_name, channel_name|
  user = Given(%Q|a user named #{user_name}|)
  channel = Given(%Q|a share named "#{channel_name}"|)
  channel.users << user
end

Given 'a document "$document" is in the share "$channel"' do |filename, channel|
  user = Given('a user in a non-public role')
  document = user.documents.create! :file => File.open(File.expand_path(RAILS_ROOT+'/spec/fixtures/'+filename))
  document.channels << Given(%Q|a share named "#{channel}"|)
end


When 'I fill out the share invitation form with:' do |table|
  fill_in_audience_form table
end
