Given /^the following groups for "([^\"]*)" exist:$/ do |email, table|
  table.raw.each do |row|
    owner = User.find_by_email!(email)
    name, jurisdictions, roles, users, scope, owner_jurisdiction = row
    options = {:owner => owner, :name => name, :scope => scope}
    options[:jurisdictions] = Jurisdiction.find_all_by_name(jurisdictions.split(',').map(&:strip)) unless jurisdictions.blank?
    options[:owner_jurisdiction] = Jurisdiction.find_by_name(owner_jurisdiction) unless owner_jurisdiction.blank?
    options[:roles] = Role.find_all_by_name(roles.split(',').map(&:strip)) unless roles.blank?
    options[:users] = User.find_all_by_email(users.split(',').map(&:strip)) unless users.blank?
    group = FactoryGirl.create(:group, options)
   end
end

Then /^I should see the(?: (ext))? add group form$/ do |ext|
  if ext.nil?
    page.should have_css("#audience #group_name")
    page.should have_css("#audience .jurisdictions")
    page.should have_css("#audience .roles")
    page.should have_css("#audience .people")
  else
    # we're looking for the ext form here, may as well take advantage of ext and let it find the form for us
    page.evaluate_script("window.Application.phin.tabPanel.getActiveTab().getComponent('create_group_form_holder').getComponent('create_group_form').isVisible()").should == true
  end

end

Then /^I should see the following roles(?: in an (ext) grid)?:$/ do |ext, table|
  css = ext.nil? ? ".roles li" : ".roles"

  table.raw.each do |row|
    page.should have_css(css, :content => row[0])
  end
end

Then /^I should see the following group summary:$/ do |table|
  table.rows_hash.each do |key, value|
    value.split(',').each do |item|
      if key =~ /(name|group_scope|owner_jurisdiction)/i
        page.should have_css(".#{key}", :text => item)
      else
        page.should have_css(".#{key} *", :text => item)
      end
    end  
  end
end

When "I fill out the group form with:" do |table|
  fill_in_group_form table
end

When /^I import the group file "([^\"]*)"$/ do |filename|
  GroupImporter.import_groups(File.join(Rails.root.to_s, 'tmp', filename))
end

When /^I import the group file "([^\"]*)" with no update$/ do |filename|
  GroupImporter.import_groups(File.join(Rails.root.to_s, 'tmp', filename), {:no_update => true })
end

When /^the group "([^\"]*)" should(?: (not))? exist$/ do |name, not_option|
  group = Group.find_by_name(name)
  if not_option.nil?
    group.should_not be_nil
  else # if we are looking for the not option
    group.should be_nil
  end
end

Then /^the group "([^\"]*)" in "([^\"]*)" should exist$/ do |name, jurisdiction_name|
  Group.find_by_name_and_owner_jurisdiction_id(name, Jurisdiction.find_by_name(jurisdiction_name).id).should_not be_nil
end

Then /^the group "([^\"]*)" in "([^\"]*)" should not exist$/ do |name, jurisdiction_name|
  Group.find_by_name_and_owner_jurisdiction_id(name, Jurisdiction.find_by_name(jurisdiction_name).id).should be_nil
end

Then /^I should see "(.*)" as a groups option$/ do |name|
  page.should have_content(name)
end

Then /^I should see that the group includes\:$/ do |table|
  table.raw.each do |row|
    row[0].split(",").each do |name|
      page.should have_css(".group_rcpt", :content => name.strip)
    end
  end
end

Then /^I should see the user "(.*)" immediately before "(.*)"$/ do |user1, user2|
   page.should have_css("li.group_rcpt:nth-child(1)", :content => user1)
   page.should have_css("li.group_rcpt:nth-child(2)", :content => user2)
end

Then /^the "([^\"]*)" group should have the following members:$/ do |name, table|
  group = Group.find_by_name(name)
  table.rows_hash.each do |key, value|
    case key
    when "User"
      group.users.include?(User.find_by_email(value)).should be_true
    when "Jurisdiction"
      group.jurisdictions.include?(Jurisdiction.find_by_name(value)).should be_true
    when "Role"
      group.roles.include?(Roles.find_by_name(value)).should be_true
    else
      raise "I don't know what '#{key}' means, please fix the step definition in #{__FILE__}"
    end
  end
  end

Then /^the "([^\"]*)" group should not have the following members:$/ do |name, table|
  group = Group.find_by_name(name)
  table.rows_hash.each do |key, value|
    case key
    when "User" 
      group.users.include?(User.find_by_email(value)).should be_false
    when "Jurisdiction"
      group.jurisdictions.include?(Jurisdiction.find_by_name(value)).should be_false
    when "Role"
      group.roles.include?(Roles.find_by_name(value)).should be_false
    else
      raise "I don't know what '#{key}' means, please fix the step definition in #{__FILE__}"
    end
  end
end

Then /^the "([^\"]*)" group in "([^\"]*)" should have the following members:$/ do |name, jurisdiction_name, table|
  group = Group.find_by_name_and_owner_jurisdiction_id(name, Jurisdiction.find_by_name(jurisdiction_name).id)
  table.rows_hash.each do |key, value|
    case key
    when "User"
      group.users.include?(User.find_by_email(value)).should be_true
    when "Jurisdiction"
      group.jurisdictions.include?(Jurisdiction.find_by_name(value)).should be_true
    when "Role"
      group.roles.include?(Roles.find_by_name(value)).should be_true
    else
      raise "I don't know what '#{key}' means, please fix the step definition in #{__FILE__}"
    end
  end
  end

Then /^the "([^\"]*)" group in "([^\"]*)" should not have the following members:$/ do |name, jurisdiction_name, table|
  group = Group.find_by_name_and_owner_jurisdiction_id(name, Jurisdiction.find_by_name(jurisdiction_name).id)
  table.rows_hash.each do |key, value|
    case key
    when "User"
      group.users.include?(User.find_by_email(value)).should be_false
    when "Jurisdiction"
      group.jurisdictions.include?(Jurisdiction.find_by_name(value)).should be_false
    when "Role"
      group.roles.include?(Roles.find_by_name(value)).should be_false
    else
      raise "I don't know what '#{key}' means, please fix the step definition in #{__FILE__}"
    end
  end
end

Then /^I should see an error "([^\"]*)"$/ do |error|
  IO.read('log/group.log').include?(error).should be_true
end
