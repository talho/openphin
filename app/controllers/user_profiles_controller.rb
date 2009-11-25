class UserProfilesController < ApplicationController
	app_toolbar "accounts"
	
  before_filter(:except => [:show]) do |controller|
    controller.admin_or_self_required(:user_id)
  end

  # GET /users
  # GET /users.xml
  def index
    UserProfilesController.app_toolbar "application" unless params[:user_id] == current_user.id.to_s
    @users = User.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml { render :xml => @users }
    end
  end

  # GET /users/1
  # GET /users/1.xml
  def show
    self.class.app_toolbar "application" unless params[:user_id] == current_user.id.to_s
    @user = User.find(params[:user_id])
    
    respond_to do |format|
      if @user.public? || current_user == @user || current_user.is_admin?
        format.html # show.html.erb
        format.xml { render :xml => @user }
      else
        format.html { render :action => 'privacy'}
      end
    end
  end

  # GET /users/new
  # GET /users/new.xml
  def new
    self.class.app_toolbar "application" unless params[:user_id] == current_user.id.to_s
    User.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml { render :xml => @user }
    end
  end

  # GET /users/1/edit
  def edit
    self.class.app_toolbar "application" unless params[:user_id] == current_user.id.to_s
    find_user_and_profile
  end

  # POST /users
  # POST /users.xml
  def create
    self.class.app_toolbar "application" unless params[:user_id] == current_user.id.to_s
    @user=User.find(params[:user_id])

    respond_to do |format|
      if @user.save
        flash[:notice] = 'User was successfully created.'
        format.html { redirect_to(@user) }
        format.xml { render :xml => @user, :status => :created, :location => @user }
      else
        format.html { render :action => "new" }
        format.xml { render :xml => @user.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /users/1
  # PUT /users/1.xml
  def update
    self.class.app_toolbar "application" unless params[:user_id] == current_user.id.to_s
    find_user_and_profile

    # Profile form will return blank devices due to hidden fields used to add devices via ajax
    Device::Types.map(&:name).map(&:demodulize).each do |device_type|
      if params[device_type].values.first.blank?
        params.delete(device_type)
      end
    end

    if Device::Types.map(&:name).map(&:demodulize).include?(params[:device_type])
      @device = device_class_for(params[:device_type]).new params[params[:device_type]]
      @device.user = @user
    end

    params[:user][:role_requests_attributes].each do |index, role_request|
      if role_request[:role_id].blank? && role_request[:jurisdiction_id].blank?
        params[:user][:role_requests_attributes].delete(index)
        next
      end
      jurisdiction = Jurisdiction.find(role_request[:jurisdiction_id])
      if jurisdiction && current_user.is_admin_for?(jurisdiction)
        existing_request = RoleRequest.find_by_user_id_and_role_id_and_jurisdiction_id(params[:user_id], role_request['role_id'], role_request['jurisdiction_id'])
        if existing_request
          existing_request.destroy
        end
      end
      unless params[:user_id] == current_user.id
        role_request[:requester_id] = current_user.id 
      end
    end

    if !params[:user][:photo].blank?
      @user.photo=params[:user][:photo]
      params[:user].delete("photo")
    end

    if params[:user][:password] == "******"
      params[:user].delete("password")
      params[:user].delete("password_confirmation")
    end

    respond_to do |format|
      if (@device.nil? || @device.save) && (@user.update_attributes(params[:user]) && @user.save)
        params[:user][:role_requests_attributes].each do |index, role_requests|
          rr = @user.role_requests.find_by_role_id_and_jurisdiction_id(role_requests['role_id'], role_requests['jurisdiction_id'])
          if !rr.approved? && current_user.is_admin_for?(rr.jurisdiction)
            rr.approve!(current_user)
          end
        end
        flash[:notice] = 'Profile information saved.'
        format.html { redirect_to user_profile_path(@user) }
        format.xml { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml { render :xml => @user.errors, :status => :unprocessable_entity }
      end
    end
  end

  private
  def device_class_for(device_type)
    ("#{Device.name}::" + params[:device_type]).constantize
  end

  def find_user_and_profile
    @user = User.find(params[:user_id])
    unless @user.editable_by?(current_user)
      flash[:notice] = "You are not authorized to edit this profile."
      redirect_to :back
    end
  end
end
