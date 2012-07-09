class RoleRequestObserver < ActiveRecord::Observer  
  def after_create(role_request)
    return if role_request.approved?
    role_request.jurisdiction.admins.each do |admin|
      SignupMailer.admin_notification_of_role_request(role_request, admin).deliver
    end
  end
end
    