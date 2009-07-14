When 'I signup for an account with the following info:' do |table|
  visit new_user_path
  table.rows_hash.each do |field, value|
    case field
    when 'E-mail', 'Password', 'Password confirmation', 'First name', 'Last name', 'Preferred name'
      fill_in field, :with => value
    when 'What County', 'Preferred language'
      select value, :from => field
    else
      raise "Unknown field: #{field}"
    end
  end
  
  click_button 'Save'
end

Then '"$email" should have the "$role" role for "$jurisdiction"' do |email, role, jurisdiction|
  p=User.find_by_email!(email)
  j = Jurisdiction.find_by_name!(jurisdiction)
  r = Role.find_by_name!(role)
  m = p.role_memberships.find_by_role_id_and_jurisdiction_id(r.id, j.id)
  m.should_not be_nil
end

Given 'the user "$name" with the email "$email" has the role "$role" in "$jurisdiction"' do |name, email, role, jurisdiction|
  first_name, last_name = name.split
  user = Factory(:user, :email => email, :first_name => first_name, :last_name => last_name)
  user.role_memberships.create!(:role => Given("a role named #{role}"), :jurisdiction => Given("a jurisdiction named #{jurisdiction}"))
end

Given 'the following people exist:' do |table|
  table.rows.each do |row|
    Given %Q{the user "#{row[0]}" with the email "#{row[1]}" has the role "#{row[2]}" in "#{row[3]}"}
  end
end

Given 'I am logged in as "$email"' do |email|
  @current_user = Factory(:user, :email => email)
end

Given 'I am allowed to send alerts' do
  @current_user.role_memberships(:role => Factory(:role, :alerter => true), :jurisdiction => Factory(:jurisdiction))
end
