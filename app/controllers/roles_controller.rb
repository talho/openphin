class RolesController < ApplicationController
	
  before_filter :non_public_role_required, :except => [:index]
  before_filter :admin_required, :except => [:index]
 
  # GET /roles
  # GET /roles.xml
  def index
    respond_to do |format|
      format.html { render :html => (@alerts = Role.all)}
      format.xml  { render :xml =>  (@alerts = Role.all)}
      format.json do
        # this header is a must for CORS
        headers["Access-Control-Allow-Origin"] = "*"
        if current_user.is_sysadmin?
          roles = Role.all
        elsif current_user.is_admin?
          roles = Role.for_app(current_user.apps)
        else
          roles = Role.user_roles.for_app(current_user.apps)
        end
        render :json => roles.collect {|r| {:id => r.id, :name => r.display_name}}
      end
    end
  end

  # GET /roles/1
  # GET /roles/1.xml
  def show
    logger.warn "User id #{current_user.id} attempted to create a new role"
#    @role = Role.find(params[:id])
#
#    respond_to do |format|
#      format.html # show.html.erb
#      format.xml  { render :xml => @role }
#    end
  end

  # GET /roles/new
  # GET /roles/new.xml
  def new
    logger.warn "User id #{current_user.id} attempted to create a new role"
#    @role = Role.new
#
#    respond_to do |format|
#      format.html # new.html.erb
#      format.xml  { render :xml => @role }
#    end
  end

  # GET /roles/1/edit
  def edit
    logger.warn "User id #{current_user.id} attempted to create a new role"
#    @role = Role.find(params[:id])
  end

  # POST /roles
  # POST /roles.xml
  def create
    logger.warn "User id #{current_user.id} attempted to create a new role"
#    @role = Role.new(params[:role])
#
#    respond_to do |format|
#      if @role.save
#        flash[:notice] = 'Role was successfully created.'
#        format.html { redirect_to(@role) }
#        format.xml  { render :xml => @role, :status => :created, :location => @role }
#      else
#        format.html { render :action => "new" }
#        format.xml  { render :xml => @role.errors, :status => :unprocessable_entity }
#      end
#    end
  end

  # PUT /roles/1
  # PUT /roles/1.xml
  def update
    logger.warn "User id #{current_user.id} attempted to create a new role"
#    @role = Role.find(params[:id])
#
#    respond_to do |format|
#      if @role.update_attributes(params[:role])
#        flash[:notice] = 'Role was successfully updated.'
#        format.html { redirect_to(@role) }
#        format.xml  { head :ok }
#      else
#        format.html { render :action => "edit" }
#        format.xml  { render :xml => @role.errors, :status => :unprocessable_entity }
#      end
#    end
  end

  # DELETE /roles/1
  # DELETE /roles/1.xml
  def destroy
    logger.warn "User id #{current_user.id} attempted to create a new role"
#    @role = Role.find(params[:id])
#    @role.destroy
#
#    respond_to do |format|
#      format.html { redirect_to(roles_url) }
#      format.xml  { head :ok }
#    end
  end

protected

  def fetch_roles(options={})
    return [] if options.empty?
    if ( options[:age] && (Role.recent(1).first.updated_at.utc.to_i == options[:age]) )
      return []
    end
    method = options[:method]
    return [] unless (Role.public_methods-Role.instance_methods).include? method.to_s
    method = :all if method == :user_roles && current_user.is_admin?
    Role.send(method ? method : :all)
  end

end
