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
      when /the password edit page/i
        edit_user_password_path(current_user,"4d4d3c3c")
      when /the password edit page without a token/i
        edit_user_password_path(current_user,"")
      when /the request a role page/i
        new_role_request_path
      when /the pending requests page/i
        admin_role_requests_path
      when /the new alert page/i
        new_alert_path
      when /the alerts page/i
        alerts_path
      when /the alerts acknowledge page/i
        alerts_acknowledge_path
      when /the roles requests page for an admin/
        admin_role_requests_path
	    when /the HAN/i
	      hud_path
      when /the alert log/i
        alerts_path
      when /the user edit page/i
        edit_user_path(current_user)
      when /the edit profile page$/i
        edit_user_profile_path(current_user)
      when /the user profile page$/i
        user_profile_path(User.find_by_email!(arg))
      when /^the user account roles page$/i
        role_requests_path
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
      when /the admin add user page/i
        new_admin_user_path
      when /the groups page/i
        admin_groups_path
      when /the add groups? page/i
        new_admin_group_path
      when /the group page/i
        admin_group_path(Group.find_by_name!(arg))
      when /the edit group page/i
        edit_admin_group_path(Group.find_by_name!(arg))
      when /the add role assignments? page/i
        new_admin_role_assignment_path
      when /the add admin role requests? page/i
        new_admin_role_request_path
      when /the Documents page/i
        documents_path
      #add plugin paths here
      when /the rollcall page/i
        rollcall_path
      when /the rollcall schools page/i
        schools_path
      when /the rollcall school page/i
        school_path(School.find_by_name!(arg))
      when /^the about rollcall page$/i
        about_rollcall_path
      when /the Documents page/i
        documents_path
      when /the show destroy Share page for "(.*)"$/i
        channel = Channel.find_by_name($1)
        show_destroy_channel_path(channel)
      when /the document viewing panel/i
        documents_panel_path
    else
      raise "Can't find mapping from \"#{page_name}\" to a path."
    end
  end
end
 
World(NavigationHelpers)
