class SignupMailer < ActionMailer::Base
  default :from => DO_NOT_REPLY
  
  def signup_notification(user)
    if user.email.blank?
      logger.info "Tried to send an email signup notification for a user with no email address"
    else
      @set_pw_link = edit_user_password_url(user, :token => user.confirmation_token, :escape => false)
      mail(:to => user.email,
           :subject => "TxPhin: Welcome & Password setting")
    end
  end
  
  def org_confirmation(organization)
    if organization.nil? || organization.contact_email.blank?
      logger.info "Tried to send an email confirmation notification for an organization with no contact email address"
    else
      @confirm_link = organization_confirmation_url(organization, organization.token)
      mail(:to => organization.contact_email,
           :subject =>  "Confirm your email")
    end
  end
    
  def admin_notification_of_role_request(role_request, admin)
    if admin.formatted_email.blank?
      logger.info "Tried to send an admin notification for a role request and there are no role admins"
    else
      @role_request = role_request
      mail(:to => admin.formatted_email,
           :subject =>  "User requesting role #{role_request.role.name} in #{role_request.jurisdiction.name}")
    end
  end
  
end
