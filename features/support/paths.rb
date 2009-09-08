module NavigationHelpers
  def path_to(page_name, arg=nil)
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
      when /the pending requests page/i
        new_admin_pending_requests_path
      when /the new alert page/i
        new_alert_path
      when /the alerts page/i
        alerts_path
      when /the alerts acknowledge page/i
        alerts_acknowledge_path
      when /the roles requests page for an admin/
        admin_role_requests_path
      when /the alert log/i
        alerts_path
      when /the user edit page/i
        edit_user_path(current_user)
      when /the edit profile page$/i
        edit_user_profile_path(current_user)
      when /cancel the alert/
        edit_alert_path(Alert.last, :_action => "cancel")
      when /update the alert/
        edit_alert_path(Alert.last, :_action => "update")
      when /the new organization page/
        new_organization_path
      when /the update alert page/i
        url_for(:controller => "alerts", :action => "edit", :id => Alert.find_by_title(arg), :_action => "update")
      when /the cancel alert page/i
        url_for(:controller => "alerts", :action => "edit", :id => Alert.find_by_title(arg), :_action => "cancel")

    else
      raise "Can't find mapping from \"#{page_name}\" to a path."
    end
  end
end
 
World(NavigationHelpers)
