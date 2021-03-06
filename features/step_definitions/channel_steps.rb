Given 'a share named "$name"' do |name|
  Share.find_by_name(name) || FactoryGirl.create(:share, :name => name, :owner => current_user)
end

Given 'I created the share "$name"' do |name|
  step 'I follow "Documents"'
  step 'I wait for the "#new_share_folder" element to load'
  step 'I select "#new_share_folder" from the documents toolbar'
  step %Q|I fill in "Share Name" with "#{name}"|
  step 'I press "Create Share"'
  sleep 0.5
end

Given 'I have been added to the share "$name"' do |name|
  share = step(%Q|a share named "#{name}"|) 
  share.audience.users << current_user
  share.audience.recipients.with_refresh(:force => true)

  true
end

Given '"$email" has been added as owner to the share "$share_name"' do |email,share_name|
  user = step(%Q|a user with the email "#{email}"|)
  share = step(%Q|a share named "#{share_name}"|)
  share.audience.users << user
  share.save!
  share.audience.recipients.with_refresh(:force => true)

  user.permissions << FolderPermission.new(:share => share, :permission => 1)
  user.save!

  true
  #share.subscriptions.create!( :owner => true, :user => user )
end

Given '"$email" has been added to the share "$share_name"' do |email, share_name|
  user = step(%Q|a user with the email "#{email}"|)
  share = step(%Q|a share named "#{share_name}"|)
  share.audience.users << user
  share.audience.recipients.with_refresh(:force => true)

  true
end

Given 'a document "$document" is in the share "$share"' do |filename, share|
  user = step('a user in a non-public role')
  document = user.documents.create! :file => File.open(File.expand_path(Rails.root.to_s,'/spec/fixtures/'+filename))
  document.shares << step(%Q|a share named "#{share}"|)
end


When 'I fill out the share invitation form with:' do |table|
  fill_in_audience_form table
end
