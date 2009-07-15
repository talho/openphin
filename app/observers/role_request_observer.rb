class RoleRequestObserver < ActiveRecord::Observer
  observe RoleRequest
  
  def after_create(role_request)
    role_request.jurisdiction.admins.each do |admin|
      SignupMailer.deliver_admin_notification_of_role_request(role_request, admin)
    end
  end
end
    