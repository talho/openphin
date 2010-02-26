class Admin::OrganizationMembershipRequestsController < ApplicationController
  def index

  end
  
  def show
    @request = OrganizationMembershipRequest.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @request }
    end
  end

  def approve
    request = OrganizationMembershipRequest.find(params[:id])

    if request && current_user.is_super_admin?
      request.approve!(current_user)
      link = "<a href=\"#{user_profile_path(request.user)}\">#{request.user.display_name}</a>"
      flash[:notice]="#{link} is now a member of #{request.organization.name}"
      redirect_to dashboard_path
      #redirect_to :action => :index
    end

  end

  def deny
    
  end
end