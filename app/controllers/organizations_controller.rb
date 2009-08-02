class OrganizationsController < ApplicationController
  skip_before_filter :login_required, :only => [:new, :create]
  def new
    @organization = Organization.new(:contact => User.new)
  end


  def create
    @organization = Organization.new(params[:organization])
    @organization.contact_email = current_user.email if signed_in?
    
    if @organization.save
      if @organization.contact.blank?
        contact = Factory(:user, :display_name => @organization.contact_display_name, :email => @organization.contact_email)
      else
        contact = @organization.contact
      end
      SignupMailer.send_later(:deliver_confirmation, contact) unless signed_in?
      SignupMailer.send_later(:deliver_admin_notification_of_organization_request, @organization)
      
      flash[:notice] = "Thanks for signing your organization up, the email you specified as the organization's contact will receive an email notification upon admin approval of the organization's registration.  Once approval is received, individuals will be able to enroll themselves and associate their account with this organization."
      redirect_to dashboard_path
    else
      render 'new'
    end
  end
 
end
