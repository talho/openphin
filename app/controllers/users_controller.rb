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
      format.html # show.html.erb
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
    @selected_org = params[:organization].to_i unless params[:organization].blank? || Organization.non_foreign.find(:first, :conditions => ["id=#{params[:organization]}"]).nil?
    params[:health_professional] = "1" if @selected_org
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

    if params[:user][:organization_membership_requests_attributes].blank? || params[:user][:organization_membership_requests_attributes]["0"].blank? || params[:user][:organization_membership_requests_attributes]["0"]["organization_id"].blank?
      params[:user].delete("organization_membership_requests_attributes")
    else
      @selected_org = params[:user][:organization_membership_requests_attributes]["0"][:organization_id].to_i
    end

    unless params[:health_professional]
      params[:user][:role_requests_attributes]['0']['role_id'] = Role.public.id
      params[:user].delete("organization_membership_requests_attributes")
      params[:user].delete("description")
    end

    remove_blank_role_requests
    
    if (defined? params[:user][:role_requests_attributes]['0']['role_id']).nil? && (defined? params[:user][:role_requests_attributes]['0']['jurisdiction_id']).nil?
      params[:user].delete(:role_requests_attributes)
    end


    @user = User.new params[:user]
    respond_to do |format|
      if @user.save
        SignupMailer.deliver_confirmation(@user)
        format.html
        format.xml  { render :xml => @user, :status => :created, :location => @user }
        flash[:notice] = "Thanks for signing up! An email will be sent to #{@user.email} shortly to confirm your account. Once you've confirmed you'll be able to login to TXPhin.\n\nIf you have any questions please email support@#{DOMAIN}."
      else
        @selected_role = params[:user][:role_requests_attributes]['0']['role_id'].to_i if defined? params[:user][:role_requests_attributes]['0']['role_id']
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
      unless u.email_confirmed?
        u.confirm_email!
        u.role_requests.each do |role_request|
          next if role_request.approved?
          role_request.jurisdiction.admins.each do |admin|
            SignupMailer.deliver_admin_notification_of_role_request(role_request, admin)
          end
        end

        u.organization_membership_requests.each do |omr|
          if omr.has_invitation?
            invitation = Invitation.find_last_by_organization_id(omr.organization_id)
            omr.approve!(invitation.author)
          end
        end
        
        flash[:notice]="Your account has been confirmed."
      else
        flash[:error]="Your account has already been confirmed."
      end
    else
      flash[:error]="Invalid URL."
    end
    redirect_to root_path
  end
  
end
