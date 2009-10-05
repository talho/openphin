class Admin::UsersController < ApplicationController
  before_filter :admin_required
  #app_toolbar "han"

  def new
    @user = User.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @user }
    end
  end
  
  def create
    assign_public_role_if_no_role_is_provided
    
    @user = User.new(params[:user])
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