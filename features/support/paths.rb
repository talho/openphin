module NavigationHelpers
  def path_to(page_name)
    case page_name
    
    when /the homepage/i
      root_path
    when /the dashboard page/i
      dashboard_path
    when /the sign up page/i
      new_user_path
    when /the sign in page/i
      new_session_path
    when /the password reset request page/i
      new_password_path
    when /the request a role page/i
      new_role_request_path
    when /the alerts page/i
      alerts_path
    when /the alerts acknowledge page/i
      alerts_acknowledge_path
    when /the logs page/i
      logs_path
    when /the roles requests page for an admin/
      admin_role_requests_path
    when /the alert log/i
      alerts_path
    when /the user edit page/i
      edit_user_path(current_user)
	  when /the edit profile page$/i
	    edit_user_profile_path(current_user.profile)
    when /cancel the alert/
      edit_alert_path(Alert.last, :_action => "cancel")
    when /the new organization page/
      new_organization_path
    else
      raise "Can't find mapping from \"#{page_name}\" to a path."
    end
  end
end
 
World(NavigationHelpers)
