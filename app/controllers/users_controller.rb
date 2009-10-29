class UsersController < ApplicationController
  #app_toolbar "han"

  skip_before_filter :login_required, :only => [:new, :create, :confirm]
  before_filter(:except => [:index, :show, :new, :create, :confirm]) do |controller|
    controller.admin_or_self_required(:id)
  end

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
    @user = User.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @user }
    end
  end

  # GET /users/new
  # GET /users/new.xml
  def new
    @user = User.new
    @selected_role = Role.public.id

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @user }
    end
  end

  # GET /users/1/edit
  def edit
    @user = User.find(params[:id])
    redirect_to edit_user_profile_path(@user)
  end

  # POST /users
  # POST /users.xml
  def create
    I18n.locale = "#{I18n.locale}_signup_create"

    unless params[:health_professional]
      params[:user][:role_requests_attributes]['0']['role_id'] = Role.public.id
      params[:user].delete("organization_ids")
      params[:user].delete("description")
    end

    remove_blank_role_requests
    if params[:user][:role_requests_attributes]['0']['role_id'].blank? && params[:user][:role_requests_attributes]['0']['jurisdiction_id'].blank?
      params[:user][:role_requests_attributes]['0'] = {} if params[:user][:role_requests_attributes]['0'].nil?
      params[:user][:role_requests_attributes]['0']['role_id'] = Role.public 
    end
    

    @user = User.new params[:user]
    respond_to do |format|
      if @user.save
        SignupMailer.deliver_confirmation(@user)
        format.html
        format.xml  { render :xml => @user, :status => :created, :location => @user }
        flash[:notice] = "Thanks for signing up! An email will be sent to #{@user.email} shortly to confirm your account. Once you've confirmed you'll be able to login to TXPhin.\n\nIf you have any questions please email support@#{DOMAIN}."
      else
        @selected_role = params[:user][:role_requests_attributes]['0']['role_id'].to_i
        format.html { render :action => "new" }
        format.xml  { render :xml => @user.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /users/1
  # PUT /users/1.xml
  def update
    @user = User.find(params[:id])
    if @user.update_attributes(params[:user])
      roles=params[:role_requests]
      roles.each_value do |r|

        if r["_delete"]
          RoleMembership.destroy(r[:id]) if r[:id]
        elsif r['id'].nil?
          pr = Role.find(r["role_id"])
          pj =  r['jurisdiction_id'].nil? ? Jurisdiction.find(r["jurisdiction_id"]) : nil
          if pr.approval_required?
            flash[:notice] = "Requested role requires approval.  Your request has been logged and will be looked at by an administrator.<br/>"
            rr=RoleRequest.new
            rr.role=pr
            rr.user=@user
            rr.save
          else
            rm=@user.role_memberships.create(:role => pr)
            rm.jurisdiction = pj if pj
            @user.save
          end
        end
      end
    end
    respond_to do |format|
      if @user.valid?
        flash[:notice]= 'User was successfully updated.'
        #TODO Fix redirect_to to accept ActiveLdap object
        format.html { redirect_to(@user) }
        format.xml  { render :xml => @user, :status => :updated, :location => @user }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @user.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /users/1
  # DELETE /users/1.xml
  def destroy
    @user = User.find(params[:id])
    @user.destroy

    respond_to do |format|
      format.html { redirect_to(users_url) }
      format.xml  { head :ok }
    end
  end
  
  def confirm
    if u=User.find_by_id_and_token(params[:user_id], params[:token])
      u.confirm_email!
      flash[:notice]="Your account has been confirmed."
    else
      flash[:error]="Invalid URL."
    end
    redirect_back_or dashboard_path
  end
  
end
