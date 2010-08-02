class RolesController < ApplicationController
	app_toolbar "han"
	
  before_filter :admin_required, :except => [:mapping]
  
  def mapping
    roles = fetch_roles(params[:request])
    respond_to do |format|
      # this header is a must for CORS
      headers["Access-Control-Allow-Origin"] = "*"
      ActiveRecord::Base.include_root_in_json = false
      json = "{\"roles\": #{roles.to_json(params[:request])},\"latest_in_secs\": #{Role.latest_in_secs} }"
      format.json {render :json => json }
    end
  end

  # GET /roles
  # GET /roles.xml
  def index
    @roles = Role.all

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @roles }
    end
  end

  # GET /roles/1
  # GET /roles/1.xml
  def show
    @role = Role.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @role }
    end
  end

  # GET /roles/new
  # GET /roles/new.xml
  def new
    @role = Role.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @role }
    end
  end

  # GET /roles/1/edit
  def edit
    @role = Role.find(params[:id])
  end

  # POST /roles
  # POST /roles.xml
  def create
    @role = Role.new(params[:role])

    respond_to do |format|
      if @role.save
        flash[:notice] = 'Role was successfully created.'
        format.html { redirect_to(@role) }
        format.xml  { render :xml => @role, :status => :created, :location => @role }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @role.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /roles/1
  # PUT /roles/1.xml
  def update
    @role = Role.find(params[:id])

    respond_to do |format|
      if @role.update_attributes(params[:role])
        flash[:notice] = 'Role was successfully updated.'
        format.html { redirect_to(@role) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @role.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /roles/1
  # DELETE /roles/1.xml
  def destroy
    @role = Role.find(params[:id])
    @role.destroy

    respond_to do |format|
      format.html { redirect_to(roles_url) }
      format.xml  { head :ok }
    end
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
