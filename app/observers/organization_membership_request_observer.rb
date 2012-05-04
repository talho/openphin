class OrganizationMembershipRequestObserver < ActiveRecord::Observer
  observe OrganizationMembershipRequest
  
  def after_create(request)
    return if request.approved?
    User.with_role(Role.superadmin).each do |admin|
      OrganizationMembershipRequestMailer.admin_notification_of_organization_membership_request(request, admin).deliver
    end if request.user.email_confirmed?
  end
end
    