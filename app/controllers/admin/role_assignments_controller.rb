class Admin::RoleAssignmentsController < ApplicationController
  before_filter :admin_required
  
  def new
  end
  
  def create
    role = Role.find(params[:role_assigns][:role_id])
    jurisdiction = Jurisdiction.find(params[:role_assigns][:jurisdiction_id])
    users = User.find_all_by_id(params[:role_assigns][:user_ids])
    User.assign_role(role, jurisdiction, users)
    users.each do |user|
      AppMailer.deliver_role_assigned(role, jurisdiction, user)
    end
    connector = users.size == 1 ? "has" : "have"
    flash[:notice] = "#{users.map(&:email).to_sentence} #{connector} been approved for the role #{role.name} in #{jurisdiction.name}"
    redirect_to admin_role_requests_path
  end
end
