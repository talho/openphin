class RoleRequestsController < ApplicationController
  # GET /role_requests
  # GET /role_requests.xml
  def index
    @role_requests = RoleRequest.all

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

  # GET /role_requests/new
  # GET /role_requests/new.xml
  def new
    @role_request = RoleRequest.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @role_request }
    end
  end

  # GET /role_requests/1/edit
  def edit
    @role_request = RoleRequest.find(params[:id])
  end

  # POST /role_requests
  # POST /role_requests.xml
  def create
    @role_request = RoleRequest.new(params[:role_request])
    @role_request.requester = current_user

    respond_to do |format|
      if @role_request.save
        RoleRequestMailer.deliver_user_notification_of_role_request @role_request
        flash[:notice] = "Your request to be a #{@role_request.role.name} in #{@role_request.jurisdiction.name} has been submitted"
        format.html { redirect_to new_role_request_path }
        format.xml  { render :xml => @role_request, :status => :created, :location => @role_request }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @role_request.errors, :status => :unprocessable_entity }
      end
    end
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
    @role_request.destroy

    respond_to do |format|
      format.html { redirect_to(role_requests_url) }
      format.xml  { head :ok }
    end
  end
end
