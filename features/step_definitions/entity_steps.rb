Given 'the following entities exists:' do |table|
  table.rows_hash.each do |key, value|
     Given "a #{key.downcase} named #{value}"
  end
end

Given /^a[n]? organization named ([^\"]*)$/ do |name|
  Factory(:organization, :name => name)
end

Given 'a jurisdiction named $name' do |name|
  Jurisdiction.find_by_name(name) || Factory(:jurisdiction, :name => name)
end

Given 'a role named $name' do |name|
  Role.find_by_name(name) || Factory(:role, :name => name)
end

Given '$parent is the parent jurisdiction of:' do |parent_name, table|
  jurisdictions = table.raw.first
  parent = Given "a jurisdiction named #{parent_name}"
  jurisdictions.each do |name|
    jurisdiction = Given "a jurisdiction named #{name}"
    jurisdiction.move_to_child_of parent
  end
end

Given 'the following users belong to the $name' do |organization_name, table|
  organization = Given "an organization named #{organization_name}"
  users = table.raw.first
  users.each do |user_name|
    user = Given "a user named #{user_name}"
    organization.users << user
  end
end