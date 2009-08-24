class SignupMailer < ActionMailer::Base

  def confirmation(user)
    if user.email.blank?
      logger.info "Tried to send an email confirmation notification for a user with no email address"
    else
      recipients user.email
      from DO_NOT_REPLY
      subject "Confirm your email"
      body :confirm_link => user_confirmation_url(user, user.token)
    end
  end
  
  def org_confirmation(organization)
    if organization.nil? || organization.contact_email.blank?
      logger.info "Tried to send an email confirmation notification for an organization with no contact email address"
    else
      recipients organization.contact_email
      from DO_NOT_REPLY
      subject "Confirm your email"
      body :confirm_link => organization_confirmation_url(organization, organization.token)
    end
  end
  
  def admin_notification_of_organization_request(organization)
    user = User.with_role(Role.org_admin).all(:include => :role_memberships).map(&:formatted_email)
    if user.blank?
      logger.info "Tried to send an admin notification for an organization request and there are no organization admins"
    else
      recipients user
      from DO_NOT_REPLY
      subject "User requesting organization signup"
      body :organization => organization
    end
  end
  
  def admin_notification_of_role_request(role_request, admin)
    if admin.formatted_email.blank?
      logger.info "Tried to send an admin notification for a role request and there are no role admins"
    end
    recipients admin.formatted_email
    from DO_NOT_REPLY
    subject "User requesting role #{role_request.role.name} in #{role_request.jurisdiction.name}"
    body :role_request => role_request
  end
  
end
