class OrganizationsController < ApplicationController
  skip_before_filter :login_required, :only => [:new, :create]
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
      SignupMailer.send_later(:deliver_confirmation, @organization.contact) unless signed_in?
      SignupMailer.send_later(:deliver_admin_notification_of_organization_request, @organization)
      
      flash[:notice] = "Thanks for signing your organization up, the email you specified as the organization's contact will receive an email notification upon admin approval of the organization's registration.  Once approval is received, individuals will be able to enroll themselves and associate their account with this organization."
      redirect_to dashboard_path
    else
      render 'new'
    end
  end
 
end
