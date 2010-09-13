Given 'a share named "$name"' do |name|
  Channel.find_by_name(name) || Factory(:channel, :name => name)
end

Given 'I created the share "$name"' do |name|
  When 'I follow "Documents"'
  And 'I wait for the "#new_share_folder" element to load'
  And 'I select "#new_share_folder" from the documents toolbar'
  And %Q|I fill in "Share Name" with "#{name}"|
  And 'I press "Create Share"'
  sleep 0.5
end

Given 'I have been added to the share "$name"' do |name|
  channel = Given(%Q|a share named "#{name}"|)
  channel.users << current_user
end

Given 'I have been added as owner to the share "$name"' do |name|
  channel = Given(%Q|a share named "#{name}"|)
  channel.subscriptions.create!( :owner => true, :user => current_user )
end

Given '"$email" has been added as owner to the share "$channel_name"' do |email,channel_name|
  user = Given(%Q|a user with the email "#{email}"|)
  channel = Given(%Q|a share named "#{channel_name}"|)
  channel.subscriptions.create!( :owner => true, :user => user )
end

Given '"$email" has been added to the share "$channel_name"' do |email, channel_name|
  user = Given(%Q|a user with the email "#{email}"|)
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
