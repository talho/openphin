class OrganizationMembershipRequestMailer < ActionMailer::Base
  default from: DO_NOT_REPLY

  def user_notification_of_organization_membership_approval(organization, user, approver)
    mail(to: user.email,
         subject: "Request submitted for #{organization.name} has been approved by an admin.",
         body: "You request to be added to #{organization.name} has been approved by an admin.")
  end

  def admin_notification_of_organization_membership_request(request, admin)
    @request = request
    mail(:to => admin.email,
         :subject => "Request submitted for organization membership in #{request.organization.name}.")
  end

  def user_notification_of_organization_membership_removal(organization, user)
    mail(to: user.email,
         subject: "You have been removed from the organization #{organization.name}",
         body: "You have been removed from the organization #{organization.name}")    
  end
end