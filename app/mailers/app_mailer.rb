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
  
  def user_batch_error(email, exception_message, message="")
    recipients email
    from DO_NOT_REPLY
    subject "User batching error: #{exception_message}"
    body :exception_message => exception_message, :message => message
  end

  def user_delete_error(requester_email, message="")
    recipients requester_email
    from DO_NOT_REPLY
    subject "Deleting of user error: #{message}"
    body :message => message
  end

  def delayed_job_check(email)
    recipients email
    from DO_NOT_REPLY
    subject "Delayed Job Check - #{Time.now}"
    body
  end

end
