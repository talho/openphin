class Admin::RoleRequestsController < ApplicationController
  before_filter :admin_required
  app_toolbar "admin"
  
  # GET /role_requests
  # GET /role_requests.xml
  def index
    @role_requests = RoleRequest.unapproved.in_jurisdictions(current_user.jurisdictions)

    respond_to do |format|
      format.html
      format.ext
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
    role_req=RoleRequest.find(params[:id])
    if role_req
      if current_user.is_admin_for?(role_req.jurisdiction)
        role_req.approve!(current_user)
        respond_to do |format|
          format.html do
            link = "<a href=\"#{user_profile_path(role_req.user)}\">#{role_req.user.display_name}</a>"
            flash[:notice]="#{link} has been approved for the role #{role_req.role.name} in #{role_req.jurisdiction.name}"

            # Set referer for redirect when testing
            request.env["HTTP_REFERER"] = "/" if ENV["RAILS_ENV"] == "cucumber"
            if request.xhr?
              redirect_to :action => "index", :controller => "admin/role_requests", :format => "ext"
            else
              if params[:postback].blank?
                redirect_to :back
              else
                redirect_to params[:postback]
              end
            end
          end

          format.json do
            render :json => {:success => true}.as_json
          end
        end
      else
        respond_to do |format|
          format.html do
            flash[:error]="This resource does not exist or is not available."
            if request.xhr?
              redirect_to :action => "index", :controller => "admin/role_requests", :format => "ext"
            else
              redirect_to root_path
            end
          end

          format.json do
            render :json => {:success => false}.as_json
          end
        end
      end
    end
  end
  
  def deny
    role_req=RoleRequest.find(params[:id])
    if role_req
      if current_user.is_admin_for?(role_req.jurisdiction)
        role_req.deny!
        ApprovalMailer.deliver_denial(role_req, current_user)
        respond_to do |format|
          format.html do
            link = "<a href=\"#{user_profile_path(role_req.user)}\">#{role_req.user.display_name}</a>"
            flash[:notice]="#{link} has been denied for the role #{role_req.role.name} in #{role_req.jurisdiction.name}"

            # Set referer for redirect when testing
            request.env["HTTP_REFERER"] = "/" if ENV["RAILS_ENV"] == "cucumber"

            if request.xhr?
              redirect_to :action => "index", :controller => "admin/role_requests", :format => "ext"
            else
              if params[:postback].blank?
                redirect_to :back
              else
                redirect_to params[:postback]
              end
            end
          end

          format.json do
            render :json => {:success => true}.as_json
          end
        end
      else
        respond_to do |format|
          format.html do
            flash[:error]="This resource does not exist or is not available."
            if request.xhr?
              redirect_to :action => "index", :controller => "admin/role_requests", :format => "ext"
            else
              redirect_to root_path
            end
          end

          format.json do
            render :json => {:success => false}.as_json
          end
        end
      end
    end
  end

end
