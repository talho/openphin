class PhinRolesController < ApplicationController
  # GET /phin_roles
  # GET /phin_roles.xml
  def index
    @phin_roles = PhinRole.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @phin_roles }
    end
  end

  # GET /phin_roles/1
  # GET /phin_roles/1.xml
  def show
    @phin_role = PhinRole.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @phin_role }
    end
  end

  # GET /phin_roles/new
  # GET /phin_roles/new.xml
  def new
    @phin_role = PhinRole.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @phin_role }
    end
  end

  # GET /phin_roles/1/edit
  def edit
    @phin_role = PhinRole.find(params[:id])
  end

  # POST /phin_roles
  # POST /phin_roles.xml
  def create
    @phin_role = PhinRole.new(params[:phin_role])

    respond_to do |format|
      if @phin_role.save
        flash[:notice] = 'PhinRole was successfully created.'
        format.html { redirect_to(@phin_role) }
        format.xml  { render :xml => @phin_role, :status => :created, :location => @phin_role }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @phin_role.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /phin_roles/1
  # PUT /phin_roles/1.xml
  def update
    @phin_role = PhinRole.find(params[:id])

    respond_to do |format|
      if @phin_role.update_attributes(params[:phin_role])
        flash[:notice] = 'PhinRole was successfully updated.'
        format.html { redirect_to(@phin_role) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @phin_role.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /phin_roles/1
  # DELETE /phin_roles/1.xml
  def destroy
    @phin_role = PhinRole.find(params[:id])
    @phin_role.destroy

    respond_to do |format|
      format.html { redirect_to(phin_roles_url) }
      format.xml  { head :ok }
    end
  end
end
