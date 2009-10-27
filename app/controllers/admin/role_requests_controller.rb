class Admin::RoleRequestsController < ApplicationController
  before_filter :admin_required
  app_toolbar "admin"
  
  # GET /role_requests
  # GET /role_requests.xml
  def index
    @role_requests = RoleRequest.unapproved.in_jurisdictions(current_user.jurisdictions)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @role_requests }
    end
  end

  # GET /role_requests/1
  # GET /role_requests/1.xml
  def show
    @role_request = RoleRequest.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @role_request }
    end
  end

  # GET /role_requests/1/edit
  def edit
    @role_request = RoleRequest.find(params[:id])
  end

  # PUT /role_requests/1
  # PUT /role_requests/1.xml
  def update
    @role_request = RoleRequest.find(params[:id])

    respond_to do |format|
      if @role_request.update_attributes(params[:role_request])
        flash[:notice] = 'RoleRequest was successfully updated.'
        format.html { redirect_to(@role_request) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @role_request.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /role_requests/1
  # DELETE /role_requests/1.xml
  def destroy
    @role_request = RoleRequest.find(params[:id])
    respond_to do |format|
      if @role_request && current_user.is_admin_for?(@role_request.jurisdiction)
        @role_request.destroy
        format.html { redirect_to(admin_role_requests_path) }
        format.xml  { head :ok }
      else
        flash[:error] = "This resource does not exist or is not available."
        format.html { redirect_to(admin_role_requests_path) }
        format.xml { render :xml => @role_request.errors, :status => :unprocessable_entity }
      end
    end
  end

  def approve
    request=RoleRequest.find(params[:id])

    if request
      if current_user.is_admin_for?(request.jurisdiction)
        request.approve!(current_user)
        ApprovalMailer.deliver_approval(request)
        link = "<a href=\"#{user_profile_path(request.user)}\">#{request.user.display_name}</a>"
        flash[:notice]="#{link} has been approved for the role #{request.role.name} in #{request.jurisdiction.name}"
        redirect_to :action => :index
      end
    end
  end
  
  def deny
    request=RoleRequest.find(params[:id])
    if request
      if current_user.is_admin_for?(request.jurisdiction)
        request.deny!
        ApprovalMailer.deliver_denial(request, current_user)
        link = "<a href=\"#{user_profile_path(request.user)}\">#{request.user.display_name}</a>"
        flash[:notice]="#{link} has been denied for the role #{request.role.name} in #{request.jurisdiction.name}"
        redirect_to :action => :index
      end
    end
  end

end
