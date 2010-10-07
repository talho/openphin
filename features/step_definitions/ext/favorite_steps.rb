When /^I have a favorite named "([^\"]*)"$/ do |favorite_name|
  Factory(:favorite, :tab_config => {:id => favorite_name.downcase.gsub(" ", "_"), :title => favorite_name}, :user => current_user)
end

When /^I drag the "([^\"]*)" tab to "([^\"]*)"$/ do |tabname, target|
  page.find("li", :text => tabname).drag_to(page.find(target));
end

When /^I right click favorite button "([^\"]*)"$/ do |button|
  wait_until {!page.find('.favorite_button', :text => button).nil?}
  # So we're going to have to simulate the right click here
  page.execute_script("var cmp = Ext.getCmp(Ext.get(Ext.DomQuery.selectNode('.favorite_button:contains(#{button})')).id); Application.phin.favoritesToolbar.showContextMenu(cmp.getEl(), cmp.recordId);")
end