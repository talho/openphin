class UsersController < Clearance::UsersController
  #app_toolbar "han"

  respond_to :html, :xml

  before_filter(:only => [:edit, :update, :destroy]) do |controller|
    controller.admin_or_self_required(:id)
  end
  before_filter :redirect_to_plugin_signup, :only => :new

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
    respond_with(@user = User.new)
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
    @selected_role = params[:role_id]
    @selected_jurisdiction = params[:user][:home_jurisdiction_id]

    @user = User.new params[:user]
    @user.email = @user.email.downcase
    @user.role_requests.build role_id: params[:role_id], jurisdiction_id: @user.home_jurisdiction_id unless params[:role_id].blank?
    
    if @user.save
      # Add a public role for the current app. There should only be one, but if the setup didn't happen correctly, there may be none. Also ensure that we don't add a role that's already there
      app_role = current_app.roles.where(public: true).first
      @user.role_memberships.create role_id: app_role.id, jurisdiction_id: @user.home_jurisdiction_id unless app_role.nil? || @user.role_memberships.where(role_id: app_role.id).exists?
      
      sign_in @user
      redirect_to :root
    else
      respond_with @user
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
          unless pr.public?
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
  
  # def confirm
    # if u=User.find_by_id_and_token(params[:user_id], params[:token])
      # unless u.email_confirmed?
        # u.confirm_email!
        # u.role_requests.each do |role_request|
          # next if role_request.approved?
          # application          = role_request.role.application
          # current_jurisdiction = role_request.jurisdiction
          # admins               = current_jurisdiction.admins(application)
          # if admins.blank?
            # while current_jurisdiction.super_admins(application).blank?
              # current_jurisdiction = current_jurisdiction.parent
            # end
            # admins = current_jurisdiction.super_admins(application)
          # end
          # admins.each do |admin|
            # SignupMailer.admin_notification_of_role_request(role_request, admin).deliver
          # end
        # end
# 
        # u.organization_membership_requests.each do |omr|
          # if omr.has_invitation?
            # invitation = Invitation.find_last_by_organization_id(omr.organization_id)
            # omr.approve!(invitation.author)
          # end
        # end
#         
        # flash[:notice]="Your account has been confirmed."
      # else
        # flash[:error]="Your account has already been confirmed."
      # end
    # else
      # flash[:error]="Invalid URL."
    # end
    # redirect_to root_path
  # end
  
  def is_admin
    user = User.find_by_id(params[:user_id])
    admin = user && user.is_admin?
    superadmin = user && user.is_super_admin?
    respond_to do |format|
      format.json {render :json => {:success => true, :admin => admin, :superadmin => superadmin}}
    end
  end

  protected

  def redirect_to_plugin_signup
    unless current_app.new_user_path.blank?
      current_app.new_user_path.to_sym
    end
  end
  
end
