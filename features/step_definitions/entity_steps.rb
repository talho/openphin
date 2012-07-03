Given /^the following entities exist[s]?:$/ do |table|
  table.raw.each do |row|
    key, value, app = row
    if app.blank?
      step "a #{key.downcase} named #{value}"
    else
      step "an application #{key.downcase} named #{value} for #{app}"
    end
  end
end

Given /^a[n]? organization named (.*)$/ do |name|
  organization = Organization.find_by_name(name)
  if organization
    organization
  else
    step "a new organization named #{name}"
  end  
end

Given /^a new organization named (.*)$/ do |name|
  org = FactoryGirl.create(:organization, :name => name)
  user = FactoryGirl.create(:user)
  RoleMembership.create(:user => user, :role => Role.admin, :jurisdiction => Jurisdiction.root || FactoryGirl.create(:jurisdiction))
  org
end

Given 'a jurisdiction named $name' do |name|
  if jurisdiction=Jurisdiction.find_by_name(name)
    jurisdiction
  else
    jurisdiction = FactoryGirl.create(:jurisdiction, :name => name)
    jurisdiction.move_to_child_of(Jurisdiction.root) if Jurisdiction.root
    jurisdiction
  end
end

Given 'a child jurisdiction named $name' do |name|
  if jurisdiction=Jurisdiction.find_by_name(name)
    jurisdiction
  else
    jurisdiction = FactoryGirl.create(:jurisdiction, :name => name)
    if Jurisdiction.root
      if Jurisdiction.state.nonforeign.blank?
        state = FactoryGirl.create(:jurisdiction)
        state.move_to_child_of(Jurisdiction.root)
        jurisdiction.move_to_child_of(state)
      else
        jurisdiction.move_to_child_of(Jurisdiction.state.nonforeign.first)
      end
    else
      federal = FactoryGirl.create(:jurisdiction)
      state = FactoryGirl.create(:jurisdiction)
      state.move_to_child_of(Jurisdiction.root)
      jurisdiction.move_to_child_of(state)
    end
    jurisdiction
  end
end

Given /^a[n]? role named (.*)$/ do |name|
  Role.find_by_name_and_application(name,"phin") || FactoryGirl.create(:role, :name => name, :public => "Public" == name, :application => "phin")
end

Given /^a[n]? application role named (.*) for (.*)$/ do |name, app|
  Role.find_by_name_and_application(name,app) || FactoryGirl.create(:role, :name => name, :public => "Public" == name, :application => app)
end

Given /^a[n]? organization type named (.*)$/ do |name|
  OrganizationType.find_by_name(name) || FactoryGirl.create(:organization_type, :name => name)
end

Given /^a[n]? approval role named (.*)$/ do |name|
  Role.approval_roles.find_by_name(name) || FactoryGirl.create(:role, :name => name, :public => false)
end
Given /^a[n]? application approval role named (.*) for (.*)$/ do |name, app|
  Role.approval_roles.find_by_name_and_application(name,app) || FactoryGirl.create(:role, :name => name, :public => false, :application => app)
end

Given /^a[n]? system role named (.*)$/ do |name|
  r = Role.approval_roles.find_by_name_and_application(name, "phin") || FactoryGirl.create(:role, :name => name, :public => false, :user_role => false, :application => "phin")
end
Given /^a[n]? application system role named (.*) for (.*)$/ do |name, app|
  Role.find_by_name_and_application(name,app) || FactoryGirl.create(:role, :name => name, :public => false, :user_role => false, :application => app)
end

Given /^the role "([^\"]*)" is for the "([^\"]*)" application$/ do |role, app|
  Role.find_by_name(role).update_attributes(:application => app.downcase)
end

Given /^(.*) is the parent jurisdiction of:$/ do |parent_name, table|
  jurisdictions = table.raw.first
  # just in case the jurisdictions are delimited by comma
  unless (jurisdictions.size != 1) || (!jurisdictions.first.kind_of? String)
    jurisdictions = jurisdictions.first.split(",").map(&:strip)
  end
  parent = step "a jurisdiction named #{parent_name}"
  jurisdictions.each do |name|
    jurisdiction = step "a jurisdiction named #{name}"
    jurisdiction.move_to_child_of parent
  end
end

Given /^the following users belong to the (.*):$/ do |organization_name, table|
  organization = step "an organization named #{organization_name}"
  users = table.raw.first
  users.each do |user_name|
    user = step "a user named #{user_name}"
    organization.users << user
  end
end

Given '$name is a foreign Organization' do |name|
  Organization.find_by_name!(name).update_attributes :foreign => true, :queue => name.parameterize
end

Given '"$name" has the OID "$oid"' do |name, oid|
  organization = step "an organization named #{name}"
  organization.update_attributes :phin_oid => oid
end

Given '"$name" has the FIPS code "$code"' do |name, code|
  jurisdiction = step "a jurisdiction named #{name}"
  jurisdiction.update_attributes :fips_code => code
end

When /^an article exists$/ do
	FactoryGirl.create(:article)
end
