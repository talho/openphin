module Capybara
  class Session
    def fill_in(locator, options={})
      msg = "cannot fill in, no text field, text area or password field with id, name, or label '#{locator}' found"
      raise "Must pass a hash containing 'with'" if not options.is_a?(Hash) or not options.has_key?(:with)
      field = locate(:xpath, XPath.fillable_field(locator), msg)
      id = field.node.attribute('id') if options[:hidden]
      execute_script("Ext.getCmp('#{id}').removeClass('x-hidden')") if options[:hidden]
      if options[:htmleditor]
        execute_script("Ext.getCmp('#{id}').setValue('#{options[:with]}')")
      else
        field.set(options[:with])
      end
      execute_script("Ext.getCmp('#{id}').addClass('x-hidden')") if options[:hidden]
    end
  end
end

When /^(?:|I )fill in the hidden field "([^"]*)" with "([^"]*)"(?: within "([^"]*)")?$/ do |field, value, selector|
  with_scope(selector) do
    fill_in(field, :with => value, :hidden => true)
  end
end

When /^(?:|I )fill in this hidden field "([^"]*)" for "([^"]*)"(?: within "([^"]*)")?$/ do |value, field, selector|
  with_scope(selector) do
    fill_in(field, :with => value, :hidden => true)
  end
end

When /^(?:|I )fill in the (?:|html)editor "([^"]*)" with "([^"]*)"(?: within "([^"]*)")?$/ do |field, value, selector|
  with_scope(selector) do
    fill_in(field, :with => value, :hidden => true, :htmleditor => true)
  end
end

When /^(?:|I )fill in this (?:|html)editor "([^"]*)" for "([^"]*)"(?: within "([^"]*)")?$/ do |value, field, selector|
  with_scope(selector) do
    fill_in(field, :with => value, :hidden => true, :htmleditor => true)
  end
end

When /^I click ([a-zA-Z0-9\-_]*) "([^\"]*)"(?: within "([^\"]*)")?$/ do |class_type, button, selector|
  with_scope(selector) do
    wait_until {!page.find('.' + class_type, :text => button).nil?}
    page.find('.' + class_type, :text => button).click
  end
end

When /^I wait until I have (\d*) ext menus$/ do |number|
  wait_until { page.all('.x-menu').length == number.to_i }
end

When /^I navigate to "([^\"]*)"$/ do |menu_navigation_list|
  menu_array = menu_navigation_list.split('>').map{|x| x.strip}

  tb_button = menu_array.delete_at(0)

  When %Q{I press "#{tb_button}"}

  menu_array.each do |menu|
    When %Q{I click x-menu-item "#{menu}"}
  end
end

When /^(?:|I )navigate to ([^\"]*)$/ do |path|
  path_lookup = {
    "the rollcall dashboard page".to_sym => "Rollcall > Main",
    "the rollcall ADST page".to_sym => "Rollcall > ADST",
    "the new invitation page".to_sym => "Admin > Manage Invitations > Invite Users",
    "the invitations page".to_sym => "Admin > Manage Invitations > View Invitations"
  }

  When %Q{I go to the ext dashboard page}
  When %Q{I navigate to "#{path_lookup[path.to_sym]}"}
end

Then /^I should see the following toolbar items in "([^\"]*)":$/ do |name, table|
  within(:css, "##{name}") do
    table.rows.each do |row|
      value = row[0]
      within(:css, ".x-toolbar-cell") { page.should have_content(value) }
    end
    false
  end
end

Then /^I should not see the following toolbar items in "([^\"]*)":$/ do |name, table|
  within(:css, "##{name}") do
    table.rows.each do |row|
      value = row[0]
      within(:css, ".x-toolbar-cell") { page.should_not have_content(value) }
    end
    false
  end
end

Then /^I should see the following ext menu items(?: within "([^"]*)")?:$/ do |selector, table|
  with_scope(selector) do
    menus = page.all('.x-menu')
    menu_lists = []

    menus.each do |menu|
      found = []
      table.hashes.each do |hash|
        items = menu.all(:xpath, ".//*[contains(concat(' ', @class, ' '), ' x-menu-item ')]", :text => hash[:name])
        items.length.should <= 1 # We either found 1 item or 0 items. There may be different menus in the system with the same name, but not until a single menu
        items.each {|item| found.push(item)}
      end
      menu_lists.push(found)
    end
    # find a menu that matches exactly what we're looking for
    menu_lists.map{|found| found.length}.include?(table.rows.length).should == true
 end
end

Then /^I should not see the following ext menu items(?: within "([^"]*)")?:$/ do |selector, table|
  with_scope(selector) do
    table.hashes.each do |hash|
      page.should_not have_xpath(".//*[contains(concat(' ', @class, ' '), ' x-menu-item ')]", :text => hash[:name])
    end
  end
end

Then /^I should have "([^\"]*)" within "([^\"]*)"$/ do |elem, selector|
  with_scope(selector) do
    page.find(elem).nil?.should == false
  end
end

Then /^the "([^\"]*)" tab should be open(?: and (active|inactive))?$/ do |tab_name, activity|
  active = activity.nil? ? true : activity == 'active'
  begin
    check_for_tab_strip_item(active, tab_name) # this first time may fail because of an element in the tab panel being removed. if so, try again
  rescue Selenium::WebDriver::Error::ObsoleteElementError # only rescue if it's this specific error
    check_for_tab_strip_item(active, tab_name) # this should succeed if the first fails.
  end
end

def check_for_tab_strip_item(active, tab_name)
  if active
    page.should have_css(".x-tab-strip li.x-tab-strip-active", :text => tab_name)
  else
    page.should have_css(".x-tab-strip li", :text => tab_name)
    page.should_not have_css(".x-tab-strip li.x-tab-strip-active", :text => tab_name)
  end
end

When /^the "([^\"]*)" tab should not be open$/ do |tab_name|
  page.should_not have_css(".x-tab-strip li", :text => tab_name)
end

def force_open_tab(tab_name, tab_url, config = nil)
  tab_config = "{title:'#{tab_name}', url:'#{tab_url}'}"
  tab_config = config unless config.nil?
  page.execute_script("window.Application.phin.open_tab(#{tab_config})")
end

When /^I close the active ext window$/ do
  page.execute_script("Ext.WindowMgr.getActive().close();")
end

When /^I close the active tab$/ do
 find('.x-tab-strip-active .x-tab-strip-close').click
end

When /^I open ext combo "([^\"]*)"$/ do |select_box|
  field = find_field(select_box)
  field.click
end

When /^I select "([^\"]*)" from ext combo "([^\"]*)"$/ do |value, select_box|
  When %Q{I open ext combo "#{select_box}"}
  When %Q{I click x-combo-list-item "#{value}"}
end

Then /^the "([^\"]*)" field should be invalid$/ do |field_name|
  field = find_field(field_name)
  if field.nil?
    field = page.find(:xpath, "//div[@id=//label[contains(text(), '#{field_name}')]/@for]") # handle the checkbox group case where it is a div and not an input or text area or other form of field
  end
  field.find(:xpath, ".[contains(concat(' ', @class, ' '), 'x-form-invalid')]").should_not be_nil
end

Then /^the following fields should be invalid:$/ do |table|
  table.rows.each do |row|
    Then %Q{the "#{row[0]}" field should be invalid}
  end
end

When /^I expand ext panel "([^\"]*)"$/ do |panel_name|
  page.find(:xpath, "//div[./*/text()= '#{panel_name}']/div[contains(concat(' ', @class, ' '), ' x-tool-toggle ')]").click
end

When /^I should see a display form with:$/ do |table|
  # table is a | Message  | For more details, keep on reading...         |
  table.rows_hash.each do |name, value|
    Then %{I should see "#{value}" within display field "#{name}"}
    #page.should have_xpath("//div[@id=//label[contains(text(), '#{name}')]/@for]", :text => value)
  end
end

When /^I should see "([^"]*)" within display field "([^"]*)"/ do |value, name|
  page.should have_xpath("//div[@id=//label[contains(text(), '#{name}')]/@for]", :text => value)
end

When /^I wait for the "([^\"]*)" mask to go away$/ do |mask_text|
  begin
    mask = page.find('.x-mask-loading', :text => mask_text)
    end_time = Time.now + 5 # wait a max of 5 seconds for the mask to disappear
    while !mask.nil? and Time.now < end_time
      mask = page.find('.x-mask-loading', :text => mask_text)
    end
    mask.should be_nil
  rescue Selenium::WebDriver::Error::ObsoleteElementError
    # this is perfect, the element has gone from the dom.
  end
end

Then /^I should not be able to navigate to "([^\"]*)"$/ do |menu_navigation_list|
  menu_array = menu_navigation_list.split('>').map{|x| x.strip}

  tb_button = menu_array.delete_at(0)

  begin
    When %Q{I press "#{tb_button}"}

    menu_array.each do |menu|
      When %Q{I click x-menu-item "#{menu}"}
    end

    menu_item_found = true
  rescue Capybara::TimeoutError
    menu_item_found = false # if it times out, we know that we were unable to find the error
  end

  menu_item_found.should be_false
end

When /^I click to download the file "([^\"]*)"$/ do |value|
  elem = page.find("button", :text => value)
  begin
    evaluate_script("window.open = function(url){setTimeout(function(){$.get(url,function(data){alert('Success')})},500);}")
    elem.click
    sleep 1
  rescue Capybara::NotSupportedByDriverError
  end
end

Then /^the "([^\"]*)" window should be open$/ do |window_title|
  page.evaluate_script("Ext.WindowMgr.getActive().title").should == window_title
end

When /^I should see "([^\"]*)" (\d) times? within "([^\"]*)"$/ do |item_name, number, selector|
   with_scope(selector) do
     page.all(:xpath, "//*[./text() = '#{item_name}']").length.should == number.to_i
   end
end

When /^(?:I )?sleep (\d+)/ do |sec|
  sleep(sec.to_f)
end

Then /^ext ([a-zA-Z0-9\-_]*) "([^\"]*)" should be hidden$/ do |class_name, content|
  page.find(".#{class_name}", :text => content).should be_nil
end

When /^ext ([a-zA-Z0-9\-_]*) "([^\"]*)" should be visible$/ do |class_name, content|
  page.find(".#{class_name}", :text => content).should_not be_nil
end

Then /^I should see the image "([^\"]*)"$/ do |file_name|
  page.should have_xpath("//*/img[contains(@src, '#{file_name}')]")
end

When /^I force open the manage groups tab$/ do
  force_open_tab("Manage Groups", "/admin_groups")
end

When /^I force open the new group tab$/ do
  force_open_tab( "Create New Group", "/admin_groups/new")
end

When /^I force open the group detail tab$/ do
  force_open_tab("Group Detail","/admin_groups/#{Group.find(:all).first[:id]}")
end

When /^I force open the edit group tab$/ do
  force_open_tab("Edit Group","/admin_groups/#{Group.find(:all).first[:id]}/edit")
end