
class Admin::RolesController < ApplicationController
  respond_to :json
  
  def index
    respond_with(@roles = Role.where(params[:app_id] ? {app_id: params[:app_id]} : ""))
  end

  def create
    @role = Role.new params[:role]
    if @role.save
      render 'application/success'
    else
      respond_with @errors = @role.errors, status: 400 do |format|
        format.any { render 'application/failure' }
      end
    end
  end

  def update
    @role = Role.find params[:id]
    if @role.update_attributes params[:role]
      render 'application/success'
    else
      respond_with @errors = @role.errors, status: 400 do |format|
        format.any { render 'application/failure' }
      end
    end
  end

  def destroy
    @role = Role.find params[:id]
    if @role.destroy
      render 'application/success'
    else
      respond_with @errors = @role.errors, status: 400 do |format|
        format.any { render 'application/failure' }
      end
    end
  end
end
