class SignupMailer < ActionMailer::Base
  
  def confirmation(user)
    recipients user.email
    from EMAIL_FROM
    subject "Confirm your email"
    body :confirm_link => user_confirmation_url(user, user.token)
  end
  
  def admin_notification_of_organization_request(organization)
    recipients User.with_role(Role.org_admin).all(:include => :role_memberships).map(&:formatted_email)
    from EMAIL_FROM
    subject "User requesting organization signup"
    body :organization => organization
  end
  
  def admin_notification_of_role_request(role_request, admin)
    recipients admin.formatted_email
    from EMAIL_FROM
    subject "User requesting role #{role_request.role.name} in #{role_request.jurisdiction.name}"
    body :role_request => role_request
  end
  
end