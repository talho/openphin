class OrganizationsController < ApplicationController

  skip_before_filter :login_required, :only => [:new, :create, :confirmation]
  protect_from_forgery :except => [:confirmation]
  app_toolbar "han"

  def new
    @organization = Organization.new(:contact => User.new)
  end

  def confirmation
    @organization = Organization.find_by_token(params[:token])

    unless @organization.nil?
      @organization.update_attribute(:email_confirmed, true)
      SignupMailer.send_later(:deliver_admin_notification_of_organization_request, @organization)
      flash[:completed] = "Your organization is confirmed.  You will be contacted by your TXPhin administrator when your registration is approved."
    else
      flash[:error] = "Your email is not registered with any organization in TXPhin."
    end
    redirect_to root_path
  end

  def create
    jurisdiction_ids = params[:organization][:jurisdiction_ids]
    params[:organization].delete('jurisdiction_ids')
    @organization = Organization.new(params[:organization])

    if @organization.save
      jurisdiction_ids.each do |jurisdiction_id|
        @organization.organization_requests.create!(:jurisdiction_id => jurisdiction_id)
      end

      SignupMailer.send_later(:deliver_org_confirmation, @organization)
      flash[:notice] = "Thank you for registering your organization with TXPhin. You will receive an email notification at the organization's email address upon administrator approval of the organization's registration.  Once approval is granted, individuals will be able to enroll themselves and associate their account with this organization."
      redirect_to dashboard_path
    else
      render 'new'
    end
  end  
 
end
