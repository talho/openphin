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

    if params[:user][:organization_membership_requests_attributes].blank? || params[:user][:organization_membership_requests_attributes]["0"].blank? || params[:user][:organization_membership_requests_attributes]["0"]["organization_id"].blank?
      params[:user].delete("organization_membership_requests_attributes")
    else
      @selected_org = params[:user][:organization_membership_requests_attributes]["0"][:organization_id].to_i
    end

    unless params[:health_professional]
      params[:user][:role_requests_attributes]['0']['role_id'] = Role.public.id if params[:user].has_key?(:role_requests_attributes)
      params[:user].delete("organization_membership_requests_attributes")
      params[:user].delete("description")
    end

    if params[:user].has_key?(:role_requests_attributes)
      remove_blank_role_requests
      if params[:user][:role_requests_attributes]['0']['role_id'].blank? && params[:user][:role_requests_attributes]['0']['jurisdiction_id'].blank?
        params[:user][:role_requests_attributes]['0'] = {} if params[:user][:role_requests_attributes]['0'].nil?
        params[:user][:role_requests_attributes]['0']['role_id'] = Role.public.id
      end
    end
    if params[:user].has_key?(:jurisdiction) && !params[:user][:jurisdiction].blank?
      j = Jurisdiction.find_by_name(params[:user][:jurisdiction])
      params[:user][:role_requests_attributes] = {0 => {:jurisdiction => j, :role => Role.public}}
    end

    @user = User.new params[:user]
    @user.role_requests.each { |role_request|
      role_request.requester = current_user
      role_request.approver = current_user if current_user.is_admin_for?(role_request.jurisdiction)
    }
    @user.organization_membership_requests.each { |omr| omr.requester = current_user }

    respond_to do |format|
      if @user.save
        @user.confirm_email!

        # Handle new devices and role requests (ext only)
        update_devices(params[:user][:new_devices]) if params[:user].has_key?(:new_devices)
        handle_role_requests(params[:user][:new_roles]) if params[:user].has_key?(:new_roles)

        flash[:notice] = 'The user has been successfully created.'
        format.html { redirect_to new_admin_user_path }
        format.json { render :json => {:flash => flash[:notice], :type => :completed, :success => true} }
        format.xml  { render :xml => @user, :status => :created, :location => @user }
      else
        format.html { render :action => "new" }
        format.json { render :json => {:flash => nil, :type => :error, :errors => @user.errors.full_messages} }
        format.xml  { render :xml => @user.errors, :status => :unprocessable_entity }
      end
    end
  end

end
