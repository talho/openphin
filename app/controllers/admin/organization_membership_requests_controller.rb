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

  def destroy
    org = Organization.find(params[:id])
    user = User.find(params[:user_id])
    if(current_user == user || current_user.is_super_admin?)
      @request = OrganizationMembershipRequest.find_by_organization_id_and_user_id(org.id,user.id)
      @request.destroy if @request
      org.group.users.delete(user)
      OrganizationMembershipRequestMailer.deliver_user_notification_of_organization_membership_removal(org, user) unless current_user == user
    else
      flash[:error] = "You do not have permission to carry out this action."
    end
    redirect_to user_profile_path(user)
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