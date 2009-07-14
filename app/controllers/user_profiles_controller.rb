class UserProfilesController < ApplicationController
  # GET /phin_person_profiles
  # GET /phin_person_profiles.xml
  def index
    @phin_person_profiles = UserProfile.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @phin_person_profiles }
    end
  end

  # GET /phin_person_profiles/1
  # GET /phin_person_profiles/1.xml
  def show
    @phin_person_profile = UserProfile.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @phin_person_profile }
    end
  end

  # GET /phin_person_profiles/new
  # GET /phin_person_profiles/new.xml
  def new
    if params[:phin_person_id]
      @phin_person_profile = User.find(params[:phin_person_id]).build_profile
    end
    @phin_person_profile ||= UserProfile.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @phin_person_profile }
    end
  end

  # GET /phin_person_profiles/1/edit
  def edit
    @phin_person_profile = UserProfile.find(params[:id])
  end

  # POST /phin_person_profiles
  # POST /phin_person_profiles.xml
  def create
    @phin_person_profile = UserProfile.new(params[:phin_person_profile])

    respond_to do |format|
      if @phin_person_profile.save
        flash[:notice] = 'PhinPersonProfile was successfully created.'
        format.html { redirect_to(@phin_person_profile) }
        format.xml  { render :xml => @phin_person_profile, :status => :created, :location => @phin_person_profile }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @phin_person_profile.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /phin_person_profiles/1
  # PUT /phin_person_profiles/1.xml
  def update
    @phin_person_profile = UserProfile.find(params[:id])

    respond_to do |format|
      if @phin_person_profile.update_attributes(params[:phin_person_profile])
        flash[:notice] = 'PhinPersonProfile was successfully updated.'
        format.html { redirect_to(@phin_person_profile) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @phin_person_profile.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /phin_person_profiles/1
  # DELETE /phin_person_profiles/1.xml
  def destroy
    @phin_person_profile = UserProfile.find(params[:id])
    @phin_person_profile.destroy

    respond_to do |format|
      format.html { redirect_to(phin_person_profiles_url) }
      format.xml  { head :ok }
    end
  end
end
