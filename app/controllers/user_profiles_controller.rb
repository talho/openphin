class UserProfilesController < ApplicationController  
  before_filter {|controller| controller.admin_or_self_required(:user_id)}

  # GET /users
  # GET /users.xml
  def index
    @users = User.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @users }
    end
  end

  # GET /users/1
  # GET /users/1.xml
  def show
    @user = User.find(params[:user_id])

    respond_to do |format|
      if @user.public? || current_user == @user || current_user.is_admin?
        format.html # show.html.erb
        format.xml  { render :xml => @user }  
      else
        format.html { render :action => 'privacy'}
      end
    end
  end

  # GET /users/new
  # GET /users/new.xml
  def new
    User.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @user }
    end
  end

  # GET /users/1/edit
  def edit
    find_user_and_profile
  end

  # POST /users
  # POST /users.xml
  def create
		@user=User.find(params[:user_id])

    respond_to do |format|
      if @user.save
        flash[:notice] = 'User was successfully created.'
        format.html { redirect_to(@user) }
        format.xml  { render :xml => @user, :status => :created, :location => @user }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @user.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /users/1
  # PUT /users/1.xml
  def update
	find_user_and_profile
    if Device::Types.map(&:name).map(&:demodulize).include?(params[:device_type])
      @device = device_class_for(params[:device_type]).new params[params[:device_type]]
      @device.user = @user
    end
		
		params[:user][:role_requests_attributes].each do |index, role_requests|
		  if role_requests[:role_id].blank? && role_requests[:jurisdiction_id].blank?
		    params[:user][:role_requests_attributes].delete(index)
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
        flash[:notice] = 'Profile information saved.'
        format.html { redirect_to user_profile_path(@user) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @user.errors, :status => :unprocessable_entity }
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
