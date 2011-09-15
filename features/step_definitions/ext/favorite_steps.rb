When /^I have a favorite named "([^\"]*)"$/ do |favorite_name|
  Factory(:favorite, :tab_config => {:id => favorite_name.downcase.gsub(" ", "_"), :title => favorite_name}, :user => current_user)
end

When /^I drag the "([^\"]*)" tab to "([^\"]*)"$/ do |tabname, target|
  # this replaces the capybara drag_to since it has been unreliable
  page.execute_script("
    var tname = '#{tabname}';
    var tgt = '#{target.sub(/^#/,'')}';
    var config = null;
    var tab_panel = Ext.getCmp('tabpanel');
    if (tab_panel) {
      tab_panel.items.each(function(item) {
        if (item.tab_config) {
          if(item.tab_config.title == tname){
            config = item;
            return false;
          }
        }
      });
    }
    if (config.tab_config) {
      var t = Ext.getCmp(tgt);
      if (t) {
        t.dropZone.notifyDrop(null,null,{item: config});
      }
    }
  ")
end

When /^I drag the "([^"]*)" folder to "([^"]*)"$/ do |foldername, target|
  # this replaces the capybara drag_to since it has been unreliable
  page.execute_script("
    var fname = '#{foldername}';
    var tgt = '#{target.sub(/^#/,'')}';
    var folderObj = null;
    var viewId = Ext.query('.document-file-icon-view')[0].id;
    if (viewId) {
      var viewObj = Ext.getCmp(viewId);
      if (viewObj.store) {
        if (viewObj.store.data) {
          if (viewObj.store.data.items) {
            Ext.each(viewObj.store.data.items, function(item) {
              if (item.data) {
                if(item.data.name == fname){
                  folderObj = item;
                  return false;
                }
              }
            });
          }
        }
      }
    }
    if (folderObj.data) {
      var t = Ext.getCmp(tgt);
      if (t) {
        t.dropZone.notifyDrop(null,null,folderObj);
      }
    }
  ")

end

When /^I right click favorite button "([^\"]*)"$/ do |button|
  waiter do
    page.find('.favorite_button', :text => button)
    # So we're going to have to simulate the right click here
    page.execute_script("var cmp = Ext.getCmp(Ext.get(Ext.DomQuery.selectNode('.favorite_button:contains(#{button})')).id); Application.phin.favoritesToolbar.showContextMenu(cmp.getEl(), cmp.recordId);")
  end
end