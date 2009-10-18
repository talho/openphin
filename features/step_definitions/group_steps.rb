Given /^the following groups for "([^\"]*)" exist:$/ do |email, table|
  owner = User.find_by_email!(email)
  table.raw.each do |row|
    name, jurisdictions, roles, users, scope, owner_jurisdiction = row
    group = Factory(:group, :owner => owner, :name => name,
            :owner_jurisdiction => Jurisdiction.find_by_name(owner_jurisdiction),
            :jurisdictions => Jurisdiction.find_all_by_name(jurisdictions.split(',')),
            :roles => Role.find_all_by_name(roles.split(',')),
            :users => User.find_all_by_display_name(users.split(',')),
            :scope => scope)
  end
end

Then /^I should see the add group form$/ do
  response.should have_selector("#audience") do |form|
	  form.should have_selector("#group_name")
	  form.should have_selector(".jurisdictions")
    form.should have_selector(".roles")
    form.should have_selector(".people")
  end
end

Then /^I should see the following roles:$/ do |table|
  table.raw.each do |row|
    response.should have_selector(".role", :content => row[0])
  end
end

Then /^I should see the following group summary:$/ do |table|
  table.rows_hash.each do |key, value|
    value.split(',').each do |item|
      response.should have_selector(".#{key.singularize}", :content => item)
    end  
  end
end

When "I fill out the group form with:" do |table|
  fill_in_group_form table
end

Then /^I should see "(.*)" as a groups option$/ do |name|
  group = Group.find_by_name!(name)
  response.should have_selector("input[name='alert[group_ids][]']", :value => group.id.to_s)
end
Then /^I should see that the group includes\:$/ do |table|
  table.raw.each do |row|
    row[0].split(",").each do |name|
      response.should have_selector(".group_rcpt", :content => name.strip)
    end
  end
end