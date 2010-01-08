class Admin::GroupsController < ApplicationController
  before_filter :admin_required
  app_toolbar "admin"

  def index
    page = params[:page].blank? ? "1" : params[:page]
    @reverse = params[:reverse] == "1" ? nil : "&reverse=1"
    @sort = params[:sort]
    case @sort
      when "owner"
        groups = current_user.viewable_groups.sort_by{|group| group.owner.display_name}
      when "scope"
        groups = current_user.viewable_groups.sort_by{|group| group.scope}
      else
        groups = current_user.viewable_groups.sort_by{|group| group.name}
    end
    groups.reverse! if params[:reverse] == "1"
    @groups = groups.paginate(:page => page, :per_page => 10)
    @page = (page == "1" ? "?" : "?page=#{params[:page]}")
  end

  def show
    group = Group.find_by_id(params[:id])
    @group = group if current_user.viewable_groups.include?(group) 
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
    group = Group.find_by_id(params[:id])
    @group = group if current_user.viewable_groups.include?(group)
    if @group.nil?
      flash[:error] = "This resource does not exist or is not available."
      redirect_to admin_groups_path
    else
      params[:group]["jurisdiction_ids"] = [] if params[:group]["jurisdiction_ids"].blank?
      params[:group]["role_ids"] = [] if params[:group]["role_ids"].blank?
      params[:group]["user_ids"] = [] if params[:group]["user_ids"].blank?
      @group.update_attributes(params[:group])

      respond_to do |format|
        if @group.save
          format.html { redirect_to admin_group_path(@group)}
          format.xml  { render :xml => @group, :status => :created, :location => @group }
          flash[:notice] = "Successfully updated the group #{params[:group][:name]}."
        else
          format.html { render :action => "edit" }
          format.xml  { render :xml => @group.errors, :status => :unprocessable_entity }
        end
      end
    end 
  end

  def edit
    group = Group.find_by_id(params[:id])
    @group = group if current_user.viewable_groups.include?(group)
    if @group.nil?
          flash[:error] = "This resource does not exist or is not available."
          redirect_to admin_groups_path
    end 
  end
  
  def dismember
    group = Group.find(params[:group_id])
    the_group = group if current_user.viewable_groups.include?(group)
    member = User.find(params[:member_id])
    the_group.users.delete(member) if the_group && member
    redirect_to(edit_admin_group_path(the_group))
  end


  def destroy
    group = Group.find(params[:id])
    @group = group if current_user.viewable_groups.include?(group)
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
