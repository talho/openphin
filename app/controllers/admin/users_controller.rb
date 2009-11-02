class Admin::UsersController < ApplicationController
  before_filter :admin_required
  app_toolbar "admin"

  def new
    @user = User.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @user }
    end
  end
  
  def create
    I18n.locale = "#{I18n.locale}_signup_create"
    unless params[:health_professional]
      params[:user][:role_requests_attributes]['0']['role_id'] = Role.public
      params[:user].delete("organization_ids")
      params[:user].delete("description")
    end

    remove_blank_role_requests
    if params[:user][:role_requests_attributes]['0']['role_id'].blank? && params[:user][:role_requests_attributes]['0']['jurisdiction_id'].blank?
      params[:user][:role_requests_attributes]['0'] = {} if params[:user][:role_requests_attributes]['0'].nil?
      params[:user][:role_requests_attributes]['0']['role_id'] = Role.public 
    end
    
    @user = User.new params[:user]
    @user.role_requests.each do |role_request|
      role_request.requester = current_user
      if current_user.is_admin_for?(role_request.jurisdiction)
        role_request.approver = current_user
      end
    end
    respond_to do |format|
      if @user.save
        @user.confirm_email!
        @user.role_requests.each do |role_request|
          if current_user.is_admin_for?(role_request.jurisdiction)
            ApprovalMailer.deliver_approval(role_request)
          end
        end
        flash[:notice] = 'The user has been successfully created.'
        format.html { redirect_to dashboard_path }
        format.xml  { render :xml => @user, :status => :created, :location => @user }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @user.errors, :status => :unprocessable_entity }
      end
    end
  end

end