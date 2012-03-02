class Admin::OrganizationMembershipRequestsController < ApplicationController
  before_filter :admin_required

  def index
    @requests = OrganizationMembershipRequest.unapproved.where(:organization_id => Organization.with_user(current_user))
  end
  
  def update
    request = OrganizationMembershipRequest.find(params[:id])
    request.approve!(current_user)
    
    respond_to do |format|
      format.json {render :json => {:success => true}}
    end
  end

  def destroy
    request = OrganizationMembershipRequest.find(params[:id])
    request.destroy
    
    respond_to do |format|
      format.json {render :json => {:success => true}}
    end
  end
end
