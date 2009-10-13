class Admin::GroupsController < ApplicationController
  before_filter :admin_required

  def index
    
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

  end

  def edit

  end

  def destroy
    
  end
end
