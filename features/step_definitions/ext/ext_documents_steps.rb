
Given /^I create a folder outline with "([^"]*)"$/ do |outline|
  folders = outline.split
  folders.each do |folder|
    components = folder.split(">")
    create_folder(components[0], components[1])
  end
end

When /^I create shares "([^\"]*)" shared with "([^\"]*)"$/ do |outline, user|
  shares = outline.split
  shares.each do |share|
    comp = share.split(">")
    base_folder = Folder.find_by_name(comp[0])
    if base_folder.nil? #set up base sharing
      f = Folder.new :name => comp[0], :user_id => current_user.id, :shared => 'shared', :audience => {:user_ids => [User.find_by_email(user).id]}
      f.save
      f.audience.recipients.length
    end
    create_folder(comp[0], comp[1])
  end
end

def create_folder(folder, sub)
  f = Folder.find_by_name(folder)
  if(f.nil?)
    f = Folder.new :name => folder, :user_id => current_user.id
    f.save
  end
  unless sub.nil?
    Folder.create :name => sub, :user_id => current_user.id, :parent_id => f.id 
  end
end

When /^I expand the folders "([^\"]*)"$/ do |expand|
  When %Q{I click ux-maximgb-tg-elbow-active on the "My Documents" grid row} if row_button_exists?("ux-maximgb-tg-elbow-active", "My Documents") && (row_button_exists?("ux-maximgb-tg-elbow-end-plus", "My Documents") || row_button_exists?("ux-maximgb-tg-elbow-plus", "My Documents"))
  folders = expand.split
  folders.each do |folder|
    When %Q{I click ux-maximgb-tg-elbow-active on the "#{folder}" grid row} if row_button_exists?("ux-maximgb-tg-elbow-active", folder) && (row_button_exists?("ux-maximgb-tg-elbow-end-plus", folder) || row_button_exists?("ux-maximgb-tg-elbow-plus", folder))
  end
end

Then /^I should see folders in the order "([^\"]*)"$/ do |order|
  index = 2
  folders = order.split
  folders.each do |folder|
    Then %Q{I should see "#{folder}" in grid row #{index} within ".document-folder-tree-grid"}
    index += 1
  end
end

Then /^folder "([^\"]*)" should not exist$/ do |name|
  Folder.find_by_name(name).should be_nil
end

When /^I double\-click the "([^\"]*)" folder$/ do |button|
  id = page.find('.document-file-icon-view').node[:id]
  page.execute_script "
    var cmp = Ext.getCmp('#{id}');
    var index = cmp.getStore().find('name', '#{button}');
    cmp.fireEvent('dblclick', cmp, index);
  "
end

Given /^I(?: have)? uploaded "([^\"]*)" to "([^\"]*)"(?: (\d+) days ago)?$/ do |file, destination, days_past|
  file = File.new(file)
  folder = current_user.folders.find_by_name(destination)
  share = nil
  if folder.nil?
    share = current_user.shares.find_by_name(destination)
  end
  Document.create :owner_id => share.nil? ? current_user.id : share.owner.id, :file => file, :folder_id => (folder || share) ? (folder || share).id : nil, :created_at => days_past.nil? ? Time.now : days_past.to_i.days.ago
end

When /^I set "([^\"]*)" as "([^\"]*)"(?: with "([^"]*)")?$/ do |folder, sharing, user|
  folder = Folder.find_by_name(folder)

  if sharing == "shared"
    folder.update_attributes :shared => 'shared', :audience => { :user_ids => [User.find_by_email(user).id] }
    folder.audience.recipients.length if folder.audience
  elsif sharing == "inherited"
    folder.update_attributes :shared => 'inherited'
  else
    folder.update_attributes :shared => 'not_shared'
  end
end

Given /^"([^\"]*)" is an? "([^\"]*)" for "([^\"]*)"$/ do |user, permission, folder|
  folder = Folder.find_by_name(folder)

  folder.folder_permissions.create :user_id => User.find_by_email(user).id, :permission => FolderPermission::PERMISSION_TYPES[permission.downcase.to_sym]
end

When /^"([^\"]*)" performs all notifications$/ do |fname|
  folder = Folder.find_by_name(fname)
  folder.update_attributes({:notify_of_audience_addition => true, :notify_of_document_addition => true, :notify_of_file_download => true, :expire_documents => true, :notify_before_document_expiry => true})
end

When /^backgroundrb has processed the nightly documents$/ do
  require 'vendor/plugins/backgroundrb/server/lib/bdrb_server_helper.rb'
  require 'vendor/plugins/backgroundrb/server/lib/meta_worker.rb'
  require 'lib/workers/document_daily_cleanup_worker.rb'
  DocumentDailyCleanupWorker.new.clean
end

Then /^"([^\"]*)" (should not|should)? exist in folder "([^\"]*)"$/ do |file, should, folder|
  folder = Folder.find_by_name(folder)

  file = folder.documents.find_by_file_file_name(file)
  if(should == "should")
    file.should_not be_nil
  else
    file.should be_nil
  end
end