class RoleRequestsController < ApplicationController

  def new
    @role_request = RoleRequest.new
  end

  def create
    @role_request = RoleRequest.new(params[:role_request])
    @role_request.requester = current_user

    respond_to do |format|
      if @role_request.save
        RoleRequestMailer.deliver_user_notification_of_role_request @role_request
        flash[:notice] = "Your request to be a #{@role_request.role.name} in #{@role_request.jurisdiction.name} has been submitted"
        format.html { redirect_to dashboard_path }
      else
        format.html { render :action => "new" }
      end
    end
  end

  
end