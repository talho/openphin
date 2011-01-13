Given /^I view the ext profile page for "([^"]*)"$/ do |email|
  u = User.find_by_email(email)
  tab_config = "{title:'Edit Profile:#{u.first_name} #{u.last_name}', user_id:'#{u.id}', id: 'user_profile_for_#{u.id}', initializer: 'Talho.ShowProfile'}"
  force_open_tab("hello", "","#{tab_config}")
end