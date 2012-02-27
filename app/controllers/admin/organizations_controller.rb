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
    render 'show'
  end
  
  def create
    jurisdiction_ids = params[:organization][:jurisdiction_ids]
    params[:organization].delete('jurisdiction_ids')
    @organization = Organization.new(params[:organization])

    if @organization.save
      respond_to do |format|
        format.html redirect_to :action => 'show'
        format.json render 'show'
      end
      
    else
      render 'new'
    end
  end
  
  def edit
    @organization = Organization.find(params[:id])
    render 'show'
  end
  
  def update
    @organization = Organization.find(params[:id])
    
    unless @organization.update_attributes params[:organization]
      respond_to do |format|
        format.html do 
          flash[:message] = "Could not save organization. Errors: #{@organization.errors.join(', ')}"
          render :html
        end
        format.json {render :json => {:success => false, :errors => @organization.errors }, :status => 400}
      end
    else
      render 'show'
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
  
  def approve_request
    request = OrganizationMembershipRequest.find(params[:id])
    request.approve!(current_user)
    
    respond_to do |format|
      format.json render :json => {:success => true}
    end
  end

  def deny_request
    request = OrganizationMembershipRequest.find(params[:id])
    request.destroy
    
    respond_to do |format|
      format.json render :json => {:success => true}
    end
  end
end
