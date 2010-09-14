When /^I fill out the assign roles form with:$/ do |table|
  fill_in_assign_role_form table
  click_button "Assign Role"
end

When /^I maliciously post the assign role form with:$/ do |table|
  maliciously_post_assign_role_form(table)
end

When /^I maliciously post a deny for a role assignment for "([^\"]*)"$/ do |user_email|
  user = User.find_by_email!(user_email)
  role_assignment = user.role_memberships.first
  script = "var f = document.createElement('form'); " +
    "f.style.display = 'none'; " +
    "$('body').append(f); " +
    "f.method = 'POST'; " +
    "f.action = '#{role_assignment_path(role_assignment)}'; " +
    "var m = document.createElement('input'); " +
    "m.setAttribute('type', 'hidden'); " +
    "m.setAttribute('name', '_method'); " +
    "m.setAttribute('value', 'delete'); " +
    "f.appendChild(m); " +
    "f.submit();"
  page.execute_script(script)
end
