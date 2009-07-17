class Admin::OrganizationsController < ApplicationController
  def new
    @organization = Organization.new(:contact => User.new)
  end


  def create
    @organization = Organization.new(params[:organization])
    
    if signed_in?
      @organization.contact = current_user
    else
      @organization.build_contact(params[:user])
    end
    
    if @organization.save
      SignupMailer.deliver_confirmation(@organization.contact) unless signed_in?
      SignupMailer.deliver_admin_notification_of_organization_request(@organization)
      
      flash[:notice] = "Thanks for signing your organization up, the email you specified as the organization's contact will receive an email notification upon admin approval of the organization's registration.  Once approval is received, individuals will be able to enroll themselves and associate their account with this organization."
      redirect_to dashboard_path
    else
      render 'new'
    end
  end

  def approve
    if current_user.is_org_approver?
      org=Organization.find(params[:id])
      org.approved=true
      org.save
      ApprovalMailer.deliver_organization_approval(org)
      redirect_to dashboard_path
    end
  end
end
