Given "there is an unapproved $name organization" do |name|
  Factory(:organization, :name => name, :approved => false)
end

When 'I signup for an organization account with the following info:' do |table|
  visit new_organization_path
  fill_in_signup_form(table)
  click_button 'Save'
end