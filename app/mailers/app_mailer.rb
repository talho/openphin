class AppMailer < ActionMailer::Base
  default :from => DO_NOT_REPLY
  
  def role_assigned(role, jurisdiction, user, admin)
    @role = role
    @jurisdiction = jurisdiction
    @user = user
    @admin = admin
    
    mail(:to => user.email,
         :subject => "Role assigned")
  end

  def system_error(exception_message, message="")
    admins=User.with_role(Role.sysadmin)
    PHINMS_RECEIVE_LOGGER.debug "Sending system error notification to #{admins.map(&:email).join(",")}"
    unless admins.empty?
      recipients = User.with_role(Role.sysadmin).map(&:email)
    else
      recipients = "root@localhost"
    end
    @exception_message = exception_message
    @message = message
    
    mail(:to => recipients,
         :subject => "System error: #{exception_message}")
  end
  
  def user_batch_error(email, exception_message, message="")
    @exception_message = exception_message
    @message = message
    
    mail(:to => email,
         :subject => "OpenPhin:  User batching error")
  end

  def user_delete_error(requester_email, message="")
    @message = message
    
    mail(:to => requester_email,
         :subject => "Deleting of user error: #{message}")
  end

  def delayed_job_check(email)
    mail(:to => email,
         :subject => "Delayed Job Check - #{Time.now}")
  end
end
