class UserProfilesController < ApplicationController
  before_filter(:except => [:show]) do |controller|
    controller.admin_or_self_required(:user_id)
  end
  before_filter :change_include_root, :only => [:edit]
  after_filter :change_include_root_back, :only => [:edit]

  # GET /users
  # GET /users.xml
  def index
    set_toolbar
    @users = User.all

    respond_to do |format|
      format.html # show.html.erb
      format.xml { render :xml => @users }
    end
  end

  # GET /users/1
  # GET /users/1.xml
  def show
    set_toolbar
    @user = User.find(params[:user_id])
    
    respond_to do |format|
      format.html # show.html.erb
      format.xml { render :xml => @user }
    end
  end

  # GET /users/new
  # GET /users/new.xml
  def new
    set_toolbar
    User.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml { render :xml => @user }
    end
  end

  # GET /users/1/edit
  # GET /users/1.json
  def edit
    set_toolbar
    find_user_and_profile
    respond_to do |format|
      format.html
      format.json {
        rm_list = @user.is_admin? ? @user.role_memberships.all_roles : @user.role_memberships.user_roles
        role_desc = rm_list.collect { |rm|
          {:id => rm.id, :role_id => rm.role_id, :rname => Role.find(rm.role_id).to_s, :type => "role", :state => "unchanged",
          :jurisdiction_id => rm.jurisdiction_id, :jname => Jurisdiction.find(rm.jurisdiction_id).to_s }
        }
        @user.role_requests.unapproved.each { |rq|
          rq = {:id => rq.id, :role_id => rq.role_id, :rname => Role.find(rq.role_id).to_s, :type => "req", :state => "pending",
                :jurisdiction_id => rq.jurisdiction_id, :jname => Jurisdiction.find(rq.jurisdiction_id).to_s }
          role_desc.push(rq)
        }
        device_desc = @user.devices.collect { |d|
          type, value = d.to_s.split(": ")
          {:id => d.id, :type => type, :rbclass => d.class.to_s, :value => value, :state => "unchanged"}
        }
        render :json => {:user => @user, :extra => {:photo => @user.photo.url(:medium), :devices => device_desc, :role_desc => role_desc}}
      }
    end
  end

  # POST /users
  # POST /users.xml
  def create
    set_toolbar
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
    set_toolbar
    find_user_and_profile

    # Profile form will return blank devices due to hidden fields used to add devices via ajax
    Device::Types.map(&:name).map(&:demodulize).each do |device_type|
      if params.has_key?(device_type) && params[device_type].values.first.blank?
        params.delete(device_type)
      end
    end

    if Device::Types.map(&:name).map(&:demodulize).include?(params[:device_type])
      @device = device_class_for(params[:device_type]).new params[params[:device_type]]
      @device.user = @user
    end

    # Handle manage devices submission (ext only)
    if params[:user].has_key?(:devices)
      success,device_errors = update_devices(params[:user][:devices])
      respond_to do |format|
        format.json {
          if success
            render :json => {:flash => "Devices saved.", :type => :completed, :success => true}
          else
            render :json => {:flash => nil, :type => :error, :errors => device_errors}
          end
        }
      end
      return
    end

    # Handle role requests (ext only)
    if params[:user].has_key?(:rq)
      result,rq_errors = handle_role_requests(params[:user][:rq])
      respond_to do |format|
        format.json {
          case result
          when "success"
            render :json => {:flash => "Requests sent.", :type => :completed, :success => true}
          when "rollback"
            render :json => {:flash => nil, :type => :rollback, :errors => rq_errors}
          else # failure
            render :json => {:flash => nil, :type => :error, :errors => rq_errors}
          end
        }
      end
      return
    end

    if params[:user].has_key?(:role_requests_attributes)
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
    end

    omr = params[:user][:organization_membership_requests_attributes]
    omr.each do |index, request|
      params[:user][:organization_membership_requests_attributes].delete(index) if request[:organization_id].blank?
      request[:approver_id] = current_user.id if current_user.is_super_admin?
    end unless omr.nil?

    if !params[:user][:photo].blank?
      @user.photo=params[:user][:photo]
      params[:user].delete("photo")
    end

    if params[:user][:password] == "******"
      params[:user].delete("password")
      params[:user].delete("password_confirmation")
    end

    # Handle unchecked checkboxes
    params[:user][:public] = 0 if !params[:user].has_key?(:public)

    respond_to do |format|
      begin
        if @user.update_attributes(params[:user]) && (@device.nil? || @device.save)
          flash[:notice] = ""

          params[:user][:role_requests_attributes].each do |index, role_requests|
            rr = @user.role_requests.find_by_role_id_and_jurisdiction_id(role_requests['role_id'], role_requests['jurisdiction_id'])
            if !rr.approved? && current_user.is_admin_for?(rr.jurisdiction)
              rr.approve!(current_user)
            end
          end unless params[:user][:role_requests_attributes].nil?

          params[:user][:organization_membership_requests_attributes].each do |index, request|
            omr = @user.organization_membership_requests.find_by_organization_id(request['organization_id'])
            if !omr.approved? && current_user.is_super_admin?
              omr.approve!(current_user)
            else
              flash[:notice] += "Your request to be a member of #{omr.organization.name} has been sent to an administrator for approval."
            end
          end unless params[:user][:organization_membership_requests_attributes].nil?

          flash[:notice] += flash[:notice].blank? ? 'Profile information saved.' : '<br/><br/>Profile information saved.'
          format.html { redirect_to user_profile_path(@user) }
          format.json { render :json => {:flash => flash[:notice], :type => :completed, :success => true} }
          format.xml { head :ok }
        else
          format.html { render :action => "edit" }
          format.json { render :json => {:flash => nil, :type => :error, :errors => @user.errors.full_messages} }
          format.xml { render :xml => @user.errors, :status => :unprocessable_entity }
        end
      rescue ActiveRecord::StaleObjectError
        flash[:error] = "Another user has recently updated this profile, please try again."
        find_user_and_profile
        format.html { render :action => "edit"}
        format.json { render :json => {:flash => flash[:error], :type => :error, :errors => @user.errors.full_messages} }
        format.xml { render :xml => @user.errors, :status => :unprocessable_entity }
      rescue StandardError => e
        flash[:error] = "An error has occurred saving your profile, please try again."
        find_user_and_profile
        format.html { render :action => "edit" }
        format.json { render :json => {:flash => flash[:error] + "\n" + e.message, :type => :error, :errors => @user.errors.full_messages, :success => true} }
        format.xml { render :xml => @user.errors, :status => :unprocessable_entity }
      end
    end
  end

protected

  def device_class_for(device_type)
    ("#{Device.name}::" + params[:device_type]).constantize
  end

  def find_user_and_profile
    @user = User.find(params[:user_id], :include => [:role_memberships])
    unless @user.editable_by?(current_user)
      flash[:notice] = "You are not authorized to edit this profile."
      redirect_to :back
    end
  end

  def set_toolbar
    if params[:user_id] == current_user.id.to_s
      self.class.app_toolbar "accounts"
    else
      self.class.app_toolbar "application"
    end
  end
    
end
