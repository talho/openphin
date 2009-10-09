class Admin::RoleAssignmentsController < ApplicationController
  before_filter :admin_required
  app_toolbar "han"
  
  
  def new
  end
  
  def create
    jurisdiction = Jurisdiction.find(params[:role_assigns][:jurisdiction_id]) unless params[:role_assigns][:jurisdiction_id].blank?
    if jurisdiction.nil?
      flash[:error] = "No jurisdiction was specified"
      redirect_to admin_role_requests_path
    elsif current_user.is_admin_for?(jurisdiction)
      role = Role.find(params[:role_assigns][:role_id]) if params[:role_assigns][:role_id]
      if role.nil?
        flash[:error] = "No role was specified"
        redirect_to admin_role_requests_path
      else
        users = User.find_all_by_id(params[:role_assigns][:user_ids]) if params[:role_assigns][:user_ids]
        if users.nil?
          flash[:error] = "No users were specified"
          redirect_to admin_role_requests_path
        else
          User.assign_role(role, jurisdiction, users)
          users.each do |user|
            AppMailer.deliver_role_assigned(role, jurisdiction, user, current_user)
          end
          connector = users.size == 1 ? "has" : "have"
          flash[:notice] = "#{users.map(&:email).to_sentence} #{connector} been approved for the role #{role.name} in #{jurisdiction.name}"
          redirect_to admin_role_requests_path
        end 
      end
    else
      flash[:notice] = "The role assignment is outside of your authorized jurisdiction."
      redirect_to admin_role_requests_path
    end
  end
  
  def destroy
    role_assignment = RoleMembership.find(params[:id])
    if role_assignment.blank?
      flash[:notice] = "Invalid role membership specified"
      if session[:return_to].blank?
        redirect_to dashboard_path
      else
        redirect_to session[:return_to]
      end
    else
      name = role_assignment.role.name
      jurisdiction = role_assignment.jurisdiction.name
      user = role_assignment.user.display_name
      role_assignment.destroy
      flash[:notice] = "Role #{name} removed from #{user} in #{jurisdiction}"
      if session[:return_to].blank?
        redirect_to dashboard_path
      else
        redirect_to session[:return_to]
      end
    end
  end
end
