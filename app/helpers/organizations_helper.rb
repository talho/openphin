module OrganizationsHelper
  def fellow_member?(user)
    !(user.organization_membership_requests.map(&:organization_id) & 
      current_user.organization_membership_requests.map(&:organization_id)).empty?
  end
end
