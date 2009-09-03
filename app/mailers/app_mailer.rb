class AppMailer < ActionMailer::Base
  
  def role_assigned(role, jurisdiction, user, admin)
    recipients user.email
    from DO_NOT_REPLY
    subject "Role assigned"
    body :role => role, :jurisdiction => jurisdiction, :user => user, :admin => admin
  end

  def system_error(exception_message, message="")
    recipients OpenPHIN_config[:admin_emails]
    from DO_NOT_REPLY
    subject "System error: #{exception_message}"
    body :exception_message => exception_message, :message => message
  end
  
end