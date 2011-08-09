module Capybara
  class Session
    def fill_in(locator, options={})
      msg = "cannot fill in, no text field, text area or password field with id, name, or label '#{locator}' found"
      raise "Must pass a hash containing 'with'" if not options.is_a?(Hash) or not options.has_key?(:with)
      field = find(:xpath, XPath::HTML.fillable_field(locator))
      id = field['id'] if options[:hidden]
      execute_script("Ext.getCmp('#{id}').removeClass('x-hidden')") if options[:hidden]
      if options[:htmleditor]
        execute_script("Ext.getCmp('#{id}').setValue('#{options[:with]}')")
      else
        field.set(options[:with])
      end
      execute_script("Ext.getCmp('#{id}').addClass('x-hidden')") if options[:hidden]
    end

#    def within(*args)
#      new_scope = all(*args)
#      begin
#        scopes.push(new_scope.length > 1 ? new_scope : new_scope.first)
#        yield
#      ensure
#        scopes.pop
#      end
#    end

#    def method_missing(*args)
#      if(current_node.class == Array)
#        if current_node.length > 1
#          if args.length == 2
#            args << {:nowait => true}
#          elsif args.length == 3
#            args[2][:nowait] = true
#          end
#        end
#        current_node.map do |node|
#          if node.send(*args)
#            return true
#          end
#        end
#        false
#      else
#        current_node.send(*args)
#      end
#    end
  end
end

#module Capybara
#  module Node
#    module Matchers
#      def has_selector?(*args)
#        options = if args.last.is_a?(Hash) then args.last else {} end
#        p = lambda do
#          results = all(*args)
#
#          case
#          when results.empty?
#            false
#          when options[:between]
#            options[:between] === results.size
#          when options[:count]
#            options[:count] == results.size
#          when options[:maximum]
#            options[:maximum] >= results.size
#          when options[:minimum]
#            options[:minimum] <= results.size
#          else
#            results.size > 0
#          end
#        end
#        if options[:nowait]
#          p.call
#        else
#          wait_conditionally_until do
#            p.call
#          end
#        end
#      rescue Capybara::TimeoutError
#        return false
#      end
#
#      def has_content?(content, options={})
#        has_xpath?(XPath::HTML.content(content), options)
#      end
#
#      def has_no_content?(content, options={})
#        has_no_xpath?(XPath::HTML.content(content), options)
#      end
#
#      def has_button?(locator, options={})
#        has_xpath?(XPath::HTML.button(locator), options)
#      end
#
#      def has_no_button?(locator, options={})
#        has_no_xpath?(XPath::HTML.button(locator), options)
#      end
#
#      def has_checked_field?(locator, options={})
#        options[:checked] = true
#        has_xpath?(XPath::HTML.field(locator), options)
#      end
#
#      def has_unchecked_field?(locator, options={})
#        options[:unchecked] = true
#        has_xpath?(XPath::HTML.field(locator), options)
#      end
#    end
#  end
#end

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
    button = waiter do
      page.find('.' + class_type, :text => button)
    end
    if button.nil?
      raise Capybara::ElementNotFound
    else
      button.click
    end
  end
end

When /^I explicitly click ([a-zA-Z0-9\-_]*) "([^\"]*)"(?: within "([^\"]*)")?$/ do |class_type, button, selector|
  # same as above, but text must match exactly.
  with_scope(selector) do
    button = waiter do
      page.find('.' + class_type, :text => /^#{button}$/)
    end
    if button.nil?
      raise Capybara::ElementNotFound
    else
      button.click
    end
  end
end

When /^I wait until I have (\d*) ext menus$/ do |number|
  wait_until { page.all('.x-menu').length == number.to_i }
end

When /^I navigate to "([^\"]*)"$/ do |menu_navigation_list|
  menu_array = menu_navigation_list.split('>').map{|x| x.strip}

  tb_button = menu_array.delete_at(0)
  waiter do
    Then %Q{I should see "#{tb_button.strip}"}
  end
  waiter do
    When %Q{I press "#{tb_button}"}
  end

  menu_array.each do |menu|
    waiter do
      When %Q{I click x-menu-item "#{menu}"}
    end
  end
end

When /^(?:|I )navigate to ([^\"]*)$/ do |path|
  path_lookup = {
    "the ext dashboard page".to_sym => "",
    "the rollcall dashboard page".to_sym => "Rollcall > Main",
    "the rollcall ADST page".to_sym => "Rollcall > ADST",
    "the new invitation page".to_sym => "Admin > Manage Invitations > Invite Users",
    "the invitations page".to_sym => "Admin > Manage Invitations > View Invitations"
  }

  When %Q{I go to the ext dashboard page}
  if path_lookup[path.to_sym].blank?
    When %Q{I wait for the "Loading PHIN" mask to go away}
  else
    When %Q{I navigate to "#{path_lookup[path.to_sym]}"}
  end
end

Then /^I should see the following toolbar items in "([^\"]*)":$/ do |name, table|
  within("##{name}") do
    table.rows.each do |row|
      value = row[0]
      waiter do
        page.find(".x-toolbar-cell", :text => value)
      end.should_not be_nil
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
  sleep(1)
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
  sleep(1)
  with_scope(selector) do
    table.hashes.each do |hash|
      page.should_not have_xpath(".//*[contains(concat(' ', @class, ' '), ' x-menu-item ')]", :text => hash[:name])
    end
  end
end

Then /^I should (not )?have "([^\"]*)" within "([^\"]*)"$/ do |not_have, elem, selector|
  with_scope(selector) do
    element = waiter do
      page.find(elem)
    end
    if not_have
      element.should be_nil
    else
      element.should_not be_nil
    end
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
  begin
    page.should_not have_css(".x-tab-strip li", :text => tab_name)
  rescue Selenium::WebDriver::Error::ObsoleteElementError
    1==1
  end
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
  begin
    field = find_field(field_name)
  rescue Capybara::ElementNotFound
    # handle the checkbox group case where it is a div and not an input or text area or other form of field
    field = page.find(:xpath, "//div[@id=//label[contains(text(), '#{field_name}')]/@for]")
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
  value.split(',').each do |v|
    page.should have_xpath("//div[@id=//label[contains(text(), '#{name}')]/@for]", :text => /#{v.strip}/)
  end
end

When /^I wait for the "([^\"]*)" mask to go away(?: for (\d+) second[s]*)?$/ do |mask_text, wait_seconds|
  begin
    mask = page.find('.loading-indicator', :text => mask_text)
    end_time = Time.now + (wait_seconds.blank? ? 5.seconds : wait_seconds.to_i.seconds) # wait a max of 5 seconds for the mask to disappear
    while !mask.blank? and Time.now < end_time
      mask = page.find('.loading-indicator', :text => mask_text)
    end
    mask.should be_nil
  rescue Selenium::WebDriver::Error::ObsoleteElementError, Capybara::ElementNotFound
    # this is perfect, the element has gone from the dom.  Or it hasn't appeared yet.  Then this isn't perfect.
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
  rescue Capybara::TimeoutError, Capybara::ElementNotFound
    menu_item_found = false # if it times out, we know that we were unable to find the element
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

Then /^there should be no open windows$/ do
  page.evaluate_script("Ext.WindowMgr.getActive()").should be_nil
end

When /^I should see "([^\"]*)" (\d) times? within "([^\"]*)"$/ do |item_name, number, selector|
   page.all(selector, :text => item_name).length.should == number.to_i
end

When /^(?:I )?sleep (\d+)/ do |sec|
  sleep(sec.to_f)
end

Then /^ext ([a-zA-Z0-9\-_]*) "([^\"]*)" should be hidden$/ do |class_name, content|
  waiter do
    page.find(".#{class_name}", :text => content)
  end.should be_nil
end

When /^ext ([a-zA-Z0-9\-_]*) "([^\"]*)" should be visible$/ do |class_name, content|
  waiter do
    page.find(".#{class_name}", :text => content)
  end.should_not be_nil
end

Then /^I should( not)? see the image "([^\"]*)"$/ do |neg, file_name|
  if neg.nil?
    page.should have_xpath("//*/img[contains(@src, '#{file_name}')]")
  else
    page.should_not have_xpath("//*/img[contains(@src, '#{file_name}')]")
  end 
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

When /^I force open the audit log tab$/ do
  force_open_tab("Audit Log","/audits/")
end