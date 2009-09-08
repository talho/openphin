class Admin::PendingRequestsController < ApplicationController
  before_filter :admin_required

  # GET /pending_requests
  # GET /pending_requests.xml
  def index
    @role_requests = RoleRequest.unapproved.in_jurisdictions(current_user.jurisdictions)
    @organization_requests = OrganizationRequest.unapproved.in_jurisdictions(current_user.jurisdictions.admin)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => {:role_requests => @role_requests.flatten, :organization_requests => @organization_requests.flatten } }
    end
  end
end
