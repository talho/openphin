Given /^the following entities exist[s]?:$/ do |table|
  table.raw.each do |row|
    key, value = row
    Given "a #{key.downcase} named #{value}"
  end
end

Given /^a[n]? organization named (.*)$/ do |name|
  organization = Organization.find_by_name(name)
  if organization
    organization
  else
    Given "a new organization named #{name}"
  end  
end

Given /^a new organization named (.*)$/ do |name|
  org = Factory(:organization, :name => name)
  user = Factory(:user)
  RoleMembership.create(:user => user, :role => Role.admin, :jurisdiction => Jurisdiction.root || Factory(:jurisdiction))
  org.organization_requests << OrganizationRequest.create(:jurisdiction => Jurisdiction.root)
  org.organization_requests.first.approve!(user)
  org
end

Given 'a jurisdiction named $name' do |name|
  if jurisdiction=Jurisdiction.find_by_name(name)
    jurisdiction
  else
    jurisdiction = Factory(:jurisdiction, :name => name)
    jurisdiction.move_to_child_of(Jurisdiction.root) if Jurisdiction.root
    jurisdiction
  end
end

Given 'a child jurisdiction named $name' do |name|
  if jurisdiction=Jurisdiction.find_by_name(name)
    jurisdiction
  else
    jurisdiction = Factory(:jurisdiction, :name => name)
    if Jurisdiction.root
      if Jurisdiction.state.nonforeign.blank?
        state = Factory(:jurisdiction)
        state.move_to_child_of(Jurisdiction.root)
        jurisdiction.move_to_child_of(state)
      else
        jurisdiction.move_to_child_of(Jurisdiction.state.nonforeign.first)
      end
    else
      federal = Factory(:jurisdiction)
      state = Factory(:jurisdiction)
      state.move_to_child_of(Jurisdiction.root)
      jurisdiction.move_to_child_of(state)
    end
    jurisdiction
  end
end

Given 'a role named $name' do |name|
  Role.find_by_name(name) || Factory(:role, :name => name)
end

Given /^a[n]? organization type named (.*)$/ do |name|
  OrganizationType.find_by_name(name) || Factory(:organization_type, :name => name)
end


Given /^a[n]? approval role named (.*)$/ do |name|
  r = Factory(:role, :name => name, :approval_required => true)
end
Given /^a[n]? system role named (.*)$/ do |name|
  r = Factory(:role, :name => name, :approval_required => true, :user_role => false)
end
Given /^(.*) is the parent jurisdiction of:$/ do |parent_name, table|
  jurisdictions = table.raw.first
  parent = Given "a jurisdiction named #{parent_name}"
  jurisdictions.each do |name|
    jurisdiction = Given "a jurisdiction named #{name}"
    jurisdiction.move_to_child_of parent
  end
end

Given /^the following users belong to the (.*):$/ do |organization_name, table|
  organization = Given "an organization named #{organization_name}"
  users = table.raw.first
  users.each do |user_name|
    user = Given "a user named #{user_name}"
    organization.users << user
  end
end

Given '$name is a foreign Organization' do |name|
  Organization.find_by_name!(name).update_attributes :foreign => true, :queue => name.parameterize
end

Given '"$name" has the OID "$oid"' do |name, oid|
  organization = Given "an organization named #{name}"
  organization.update_attributes :phin_oid => oid
end

Given '"$name" has the FIPS code "$code"' do |name, code|
  jurisdiction = Given "a jurisdiction named #{name}"
  jurisdiction.update_attributes :fips_code => code
end
When /^an article exists$/ do
	Factory(:article)
end