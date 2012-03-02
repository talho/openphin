class Admin::OrganizationsController < ApplicationController
  before_filter :super_admin_required
  def index
    @organizations = Organization.all
    respond_to do |format|
      format.json {render 'organizations/index', :layout => false }
    end
  end

  def show
    @organization = Organization.find(params[:id])
  end

  def new
    @organization = Organization.new(:contact => User.new)
  end
  
  def create
    # set up group
    params[:organization][:group_attributes] ||= {}
    params[:organization][:group_attributes].merge!({:name => params[:organization][:name], :scope => "Organization"})
    @organization = Organization.new(params[:organization])

    respond_to do |format|
      if @organization.save
        format.json {render :json => {:success => true}}
      else
        format.json {render :json => {:success => false, :errors => @organization.errors }, :status => 400}
      end
    end
  end
  
  def edit
    @organization = Organization.find(params[:id])
  end
  
  def update
    @organization = Organization.find(params[:id])
    
    params[:organization][:group_attributes][:id] = @organization.group_id if params[:organization][:group_attributes]
    
    respond_to do |format|
      unless @organization.update_attributes params[:organization]
        format.json {render :json => {:success => false, :errors => @organization.errors }, :status => 400}
      else
        format.json {render :json => {:success => true}} 
      end
    end
  end
    
  def destroy
    @organization = Organization.find(params[:id])
    
    respond_to do |format|
      if @organization.destroy
        format.html do 
          flash[:message] = "Organization Deleted"
          redirect_to :action => 'index'
        end
        format.json {render :json => {:success => true }, :status => 200}
      else
        format.html do 
          flash[:message] = "Could not delete organization. Errors: #{@organization.errors.join(', ')}"
          render :html
        end
        format.json {render :json => {:success => false, :errors => @organization.errors }, :status => 400}
      end
    end
  end
end
