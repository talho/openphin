class UserProfilesController < ApplicationController
  # GET /user_profiles
  # GET /user_profiles.xml
  def index
    @user_profiles = UserProfile.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @user_profiles }
    end
  end

  # GET /user_profiles/1
  # GET /user_profiles/1.xml
  def show
    @user_profile = User.find(params[:user_id]).profile
    respond_to do |format|
      if @user_profile.public? || current_user == @user_profile.user
        format.html # show.html.erb
        format.xml  { render :xml => @user_profile }  
      else
        format.html { render :action => 'privacy'}
      end
    end
  end

  # GET /user_profiles/new
  # GET /user_profiles/new.xml
  def new
    if params[:user_id]
      @user_profile = User.find(params[:user_id]).build_profile
    end
    @user_profile ||= UserProfile.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @user_profile }
    end
  end

  # GET /user_profiles/1/edit
  def edit
    @user_profile = UserProfile.find(params[:user_id])
  end

  # POST /user_profiles
  # POST /user_profiles.xml
  def create
		@user=User.find(params[:user_id])
		@user_profile = @user.create_profile(params[:user_profile])

    respond_to do |format|
      if @user_profile.save
        flash[:notice] = 'UserProfile was successfully created.'
        format.html { redirect_to(@user_profile) }
        format.xml  { render :xml => @user_profile, :status => :created, :location => @user_profile }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @user_profile.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /user_profiles/1
  # PUT /user_profiles/1.xml
  def update
	  @user=User.find(params[:user_id])
		@user_profile = @user.profile
		@user.devices << Device::EmailDevice.new(params[:device]) 

    respond_to do |format|
      if @user_profile.update_attributes(params[:user_profile])
        flash[:notice] = 'Profile information saved.'
        format.html { redirect_to(@user_profile) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @user_profile.errors, :status => :unprocessable_entity }
      end
    end
  end
end
