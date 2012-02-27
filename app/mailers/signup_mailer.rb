class SignupMailer < ActionMailer::Base

  def signup_notification(user)
    if user.email.blank?
      logger.info "Tried to send an email signup notification for a user with no email address"
    else
      recipients user.email
      from DO_NOT_REPLY
      subject "TxPhin: Welcome & Password setting"
      body :set_pw_link => edit_user_password_url(user, :token => user.confirmation_token, :escape => false)
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
