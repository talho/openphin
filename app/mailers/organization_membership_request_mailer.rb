class OrganizationMembershipRequestMailer < ActionMailer::Base

  def user_notification_of_organization_membership_approval(organization, user, approver)
    recipients user.email
    from DO_NOT_REPLY
    subject "Request submitted for #{organization.name} has been approved by an admin."
    body "You request to be added to #{organization.name} has been approved by an admin."
  end

  def admin_notification_of_organization_membership_request(request, admin)
    recipients admin.email
    from DO_NOT_REPLY
    subject "Request submitted for organization membership in #{request.organization.name}."
    body :request => request
  end

  def user_notification_of_organization_membership_removal(organization, user)
    recipients user.email
    from DO_NOT_REPLY
    subject "You have been removed from the organization #{organization.name}"
    body "You have been removed from the organization #{organization.name}"    
  end
end