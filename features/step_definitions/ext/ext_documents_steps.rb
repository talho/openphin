
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
  begin
    step %Q{I expand the folder "My Documents"}
  rescue
  end
  #When %Q{I click ux-maximgb-tg-elbow-active on the "My Documents" grid row} if row_button_exists?("ux-maximgb-tg-elbow-active", "My Documents") && (row_button_exists?("ux-maximgb-tg-elbow-end-plus", "My Documents") || row_button_exists?("ux-maximgb-tg-elbow-plus", "My Documents"))
  folders = expand.split(',')
  folders.each do |folder|
    step %Q{I expand the folder "#{folder}"}
  end
end

When /^I expand the folder "([^"]*)"$/ do |folder|
  using_wait_time 0.2 do 
    page.find(:xpath, "//div[contains(concat(' ', @class, ' '), ' x-grid3-row ') and .//text()[contains(., '#{folder}')]]//div[contains(concat(' ', @class, ' '), ' ux-maximgb-tg-elbow-active ') and (contains(concat(' ', @class, ' '), ' ux-maximgb-tg-elbow-end-plus ') or contains(concat(' ', @class, ' '), ' ux-maximgb-tg-elbow-plus '))]").click
  end
end

Then /^I should see folders in the order "([^\"]*)"$/ do |order|
  index = 2
  folders = order.split
  folders.each do |folder|
    step %Q{I should see "#{folder}" in grid row #{index} within ".document-folder-tree-grid"}
    index += 1
  end
end

Then /^folder "([^\"]*)" should not exist$/ do |name|
  Folder.find_by_name(name).should be_nil
end

When /^I double\-click the "([^\"]*)" folder$/ do |button|
  id = page.find('.document-file-icon-view')['id']
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
  require 'bdrb_server_helper'
  require 'meta_worker'
  require 'workers/document_daily_cleanup_worker'
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

Given /^I create ([0-9]*) folders$/ do |num|
  num.to_i.times do
    FactoryGirl.create(:folder)
  end
end

Given /^I uploaded ([0-9]*) files into each folder ([0-9]*) days ago$/ do |num, days|
  num = num.to_i
  Folder.all.each do |folder|
    num.times do
      FactoryGirl.create(:document, {:folder => folder, :owner => folder.owner, :created_at => days.to_i.days.ago, :file => File.open("spec/fixtures/sample.wav") })
    end
  end
end

When /^I upload the file "([^"]*)"$/ do |file|
  if Capybara.current_driver == :selenium_with_chrome
    page.execute_script("
      var win = Ext.WindowMgr.getActive();
      win.insert(0, {id: 'chrome_upload_hack', xtype: 'form', fileUpload: true, padding: '5', method:'POST', url:'/documents.json', labelWidth: 30, baseParams: {'authenticity_token': FORM_AUTH_TOKEN, folder_id: win.folder_id}, items: [
        {xtype: 'textfield', inputType: 'file', fieldLabel: 'File', name: 'file', anchor: '100%'}
      ]});
      win.doLayout();
    ");
    step %Q{I attach the file "#{file}" to "File"}
    page.execute_script("Ext.getCmp('chrome_upload_hack').getForm().submit()");
  else
    step %Q{I attach the file "#{file}" to "file"}
  end
end
