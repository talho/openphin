
Then /^I should see the following toolbar items in "([^\"]*)":$/ do |name, table|
  within(:css, "##{name}") do
	 	table.rows.each do |row|
           value = row[0]
           within(:css, ".x-toolbar-cell") { page.should have_content(value) }
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

When /^I click ([a-zA-Z0-9\-]*) "([^\"]*)"(?: within "([^\"]*)")?$/ do |class_type, button, selector|
  with_scope(selector) do
    page.find('.' + class_type, :text => button).click
  end
end

When /^I wait until I have (\d*) ext menus$/ do |number|
  wait_until { page.all('.x-menu').length == number.to_i }
end

Then /^I should have "([^\"]*)" within "([^\"]*)"$/ do |elem, selector|
  with_scope(selector) do
    page.find(elem).nil?.should == false
  end
end

Then /^The "([^\"]*)" tab should be open(?: and (active|inactive))?$/ do |tab_name, activity|
  active = activity.nil? ? true : activity == 'active'

  if active
    page.should have_css(".x-tab-strip li.x-tab-strip-active", :text => tab_name)
  else
    page.should have_css(".x-tab-strip li", :text => tab_name)
    page.should_not have_css(".x-tab-strip li.x-tab-strip-active", :text => tab_name)
  end
end