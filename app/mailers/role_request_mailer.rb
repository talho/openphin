class RoleRequestMailer < ActionMailer::Base
  
  def user_notification_of_role_request(role_request)
    @role_request = role_request
    mail(
      to: role_request.user.email,
      from: DO_NOT_REPLY,
      subject: "Request submitted for #{role_request.role.name} in #{role_request.jurisdiction.name}"
    )
  end
  
end