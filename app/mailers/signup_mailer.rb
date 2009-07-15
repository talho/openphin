class SignupMailer < ActionMailer::Base
  
  def confirmation(user)
    recipients user.email
    subject "Confirm your email"
    body :confirm_link => user_confirmation_path(user, user.token)
  end
  
  def admin_notification_of_role_request(role_request, admin)
    recipients admin.email
    subject "User requesting role #{role_request.role.name} in #{role_request.jurisdiction.name}"
    body :role_request => role_request
  end
  
end