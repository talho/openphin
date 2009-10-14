class Admin::GroupsController < ApplicationController
  before_filter :admin_required
  app_toolbar "groups"

  def index
    @groups = current_user.viewable_groups
    if @groups.empty?
      render :text => "You currently have no groups.", :layout => "application"
    else
      render :partial => "group_summary", :collection => @groups, :as => :group, :layout => "application"
    end
  end

  def show
    @group = Group.find_by_id(params[:id]) 
  end

  def new
    @group = Group.new
    @group.owner = current_user
  end

  def create
    @group = current_user.groups.build(params[:group])
    @group.owner = current_user

    respond_to do |format|
      if @group.save
        format.html { redirect_to admin_group_path(@group)}
        format.xml  { render :xml => @group, :status => :created, :location => @group }
        flash[:notice] = "Successfully created the group #{params[:group][:name]}."
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @group.errors, :status => :unprocessable_entity }
      end
    end

  end

  def update
    @group = Group.find(params[:id])
    if @group.nil?
      flash[:error] = "This resource does not exist or is not available."
      redirect_to admin_groups_path
    else
      @group.update_attributes(params[:group])

      respond_to do |format|
        if @group.save
          format.html { redirect_to admin_group_path(@group)}
          format.xml  { render :xml => @group, :status => :created, :location => @group }
          flash[:notice] = "Successfully updated the group #{params[:group][:name]}."
        else
          format.html { render :action => "new" }
          format.xml  { render :xml => @group.errors, :status => :unprocessable_entity }
        end
      end
    end 
  end

  def edit
    @group = Group.find_by_id!(params[:id])
    if @group.nil?
          flash[:error] = "This resource does not exist or is not available."
          redirect_to admin_groups_path
    end 
  end

  def destroy
    @group = Group.find_by_id(params[:id])
    name = @group.name
    respond_to do |format|
      if @group && @group.destroy
        flash[:notice] = "Successfully deleted the group #{name}."
        format.html { redirect_to admin_groups_path }
        format.xml  { head :ok }
      else
        flash[:error] = "This resource does not exist or is not available."
        format.html { redirect_to admin_groups_path }
        format.xml  { render :xml => @group.errors, :status => :unprocessable_entity }
      end
    end
  end
end
