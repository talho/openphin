class AppMailer < ActionMailer::Base
  
  def role_assigned(role, jurisdiction, user)
    recipients user.email
    subject "Role assigned"
    body :role => role, :jurisdiction => jurisdiction, :user => user
  end

  def system_error(exception_message, message="")
    recipients OpenPHIN_config[:admin_emails]
    subject "System error: #{exception_message}"
    body :exception_message => exception_message, :message => message
  end
  
end