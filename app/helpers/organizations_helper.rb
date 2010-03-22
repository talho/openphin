module OrganizationsHelper
  def fellow_member?(user)
    !(user.organizations & current_user.organizations).empty?
  end
end
