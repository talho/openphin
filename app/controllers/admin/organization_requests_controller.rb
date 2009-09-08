class Admin::OrganizationRequestsController < ApplicationController
  before_filter :admin_required
  
  # GET /organization_requests
  # GET /role_requests.xml
  def index
    @organization_requests = OrganizationRequest.unapproved.in_jurisdictions(current_user.jurisdictions)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @organization_requests }
    end
  end

  # GET /organization_requests/1
  # GET /organization_requests/1.xml
  def show
    @organization_request = OrganizationRequest.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @organization_request }
    end
  end

  # GET /organization_requests/1/edit
  def edit
    @organization_request = OrganizationRequest.find(params[:id])
  end

  # PUT /organization_requests/1
  # PUT /organization_requests/1.xml
  def update
    @organization_request = OrganizationRequest.find(params[:id])

    respond_to do |format|
      if @organization_request.update_attributes(params[:organization_request])
        flash[:notice] = 'OrganizationRequest was successfully updated.'
        format.html { redirect_to(@organization_request) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @organization_request.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /organization_requests/1
  # DELETE /organization_requests/1.xml
  def destroy
    @organization_request = OrganizationRequest.find(params[:id])
    @organization_request.destroy

    respond_to do |format|
      format.html { redirect_to(admin_organization_requests_url) }
      format.xml  { head :ok }
    end
  end

  def approve
    request=OrganizationRequest.find(params[:id])

    if request
      if current_user.is_admin_for?(request.jurisdiction)
        request.approve!(current_user)
        ApprovalMailer.deliver_organization_approval(request.organization)
        link = "<a href=\"#{request.organization.contact.nil? ? "mailto:#{request.organization.contact_email}" : user_profile_path(request.organization.contact)}\">#{request.organization.contact_display_name}</a>"
        flash[:notice]="#{link} has been approved for the organization #{request.organization.name} in #{request.jurisdiction.name}"
        redirect_to :action => :index
      end
    end
  end
  
  def deny
    request=OrganizationRequest.find(params[:id])
    organization = request.organization
    jurisdiction = request.jurisdiction
    contact = organization.contact unless organization.contact.nil?
    if request
      if current_user.is_admin_for?(jurisdiction)
        ApprovalMailer.deliver_organization_denial(organization)
        link = "<a href=\"#{contact.nil? ? "mailto:#{organization.contact_email}" : user_profile_path(contact)}\">#{organization.contact_display_name}</a>"
        flash[:notice]="#{link} has been denied for the organization #{organization.name} in #{jurisdiction.name}"
        request.deny!
        redirect_to :action => :index
      end
    end
  end

end