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
