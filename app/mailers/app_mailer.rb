class AppMailer < ActionMailer::Base
  
  def role_assigned(role, jurisdiction, user, admin)
    recipients user.email
    from DO_NOT_REPLY
    subject "Role assigned"
    body :role => role, :jurisdiction => jurisdiction, :user => user, :admin => admin
  end

  def system_error(exception_message, message="")
    admins=User.with_role(Role.superadmin)
    PHINMS_RECEIVE_LOGGER.debug "Sending system error notification to #{admins.map(&:email).join(",")}"
    unless admins.empty?
      recipients User.with_role(Role.superadmin).map(&:email)
    else
      recipients "root@localhost"
    end

    from DO_NOT_REPLY
    subject "System error: #{exception_message}"
    body :exception_message => exception_message, :message => message
  end
  
end