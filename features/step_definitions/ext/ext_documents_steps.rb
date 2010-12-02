
When /^I create a folder outline with "([^"]*)"$/ do |outline|
  folders = outline.split
  folders.each do |folder|
    components = folder.split(">")
    create_folder(components[0], components[1])
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
 When %Q{I click ux-maximgb-tg-elbow-active on the "My Documents" grid row}
  folders = expand.split
  folders.each do |folder|
    When %Q{I click ux-maximgb-tg-elbow-active on the "#{folder}" grid row}
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

When /^I double\-click the "([^\"]*)" folder?$/ do |button|
  id = page.find('.document-file-icon-view').node[:id]
  page.execute_script "
    var cmp = Ext.getCmp('#{id}');
    var index = cmp.getStore().find('name', '#{button}');
    cmp.fireEvent('dblclick', cmp, index);
  "
end