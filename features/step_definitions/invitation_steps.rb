Given /^an Invitation "([^\"]*)" exists with:$/ do |name, table|
  subject = table.rows_hash["Subject"]
  organization = Organization.find_by_name(table.rows_hash["Organization"])
  body = table.rows_hash["Body"]
  Invitation.create!(:name=>name,:subject=>subject,:organization_id=>organization.id,:body=>body,:author=>current_user)
end

Then /^"([^\"]*)" is an invitee of "([^\"]*)"$/ do |invitee_email, invitation_name|
  invitation = Invitation.find_by_name(invitation_name)
  invitation.invitees.find_by_email(invitee_email).should be_true
end

Then /^"([^\"]*)" is not an invitee of "([^\"]*)"$/ do |invitee_email, invitation_name|
  invitation = Invitation.find_by_name(invitation_name)
  invitation.invitees.find_by_email(invitee_email).should be_nil
end

Then /^"([^\"]*)" should receive the invitation for "([^\"]*)"$/ do |arg1, arg2|
  pending
end

Then /^"([^\"]*)" should not receive the invitation for "([^\"]*)"$/ do |arg1, arg2|
  pending
end

Given /^invitation "([^\"]*)" has the following invitees:$/ do |invitation_name, table|
  invitation = Invitation.find_by_name(invitation_name)
  table.rows_hash.each do |name,email|
    invitation.invitees.create(:name=>name,:email=>email)
  end
end
