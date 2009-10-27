class RoleRequestsController < ApplicationController
  app_toolbar "accounts"

  def index

  end

  def new
    @role_request = RoleRequest.new
  end

  def create
    @role_request = RoleRequest.new(params[:role_request])
    @role_request.requester = current_user
    @role_request.user = current_user

    respond_to do |format|
      if @role_request.save
        if @role_request.approved?
          flash[:notice] = "You have been granted the #{@role_request.role.name} role in #{@role_request.jurisdiction.name}"
        else
          RoleRequestMailer.deliver_user_notification_of_role_request @role_request
          flash[:notice] = "Your request to be a #{@role_request.role.name} in #{@role_request.jurisdiction.name} has been submitted"
        end
        format.html { redirect_to dashboard_path }
      else
        format.html { render :action => "new" }
        format.xml { render :xml => @role_request.errors, :status => :unprocessable_entity }
      end
    end
  end

end
