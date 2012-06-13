
class Admin::AppController < ApplicationController
  
  before_filter :sys_admin_required
  
  respond_to :json
  
  def index
    respond_with @apps = App.all
  end

  def show    
    respond_with(@app = App.find(params[:id]))
  end

  def new
    respond_with @app = App.new
  end

  def create
    @app = App.build params[:app]
    if @app.save
      respond_with(@app) do |format|
        format.any { redirect_to :show }
      end
    else
      render 'application/failure', errors: @app.errors
    end
  end

  def edit
    respond_with(@app = App.find(params[:id])) do |format|
      format.any { redirect_to :show }
    end
  end

  def update
    @app = App.find(params[:id])
    if @app.update_attributes params[:app]
      render 'application/success' # We're doing ajax, on-the-fly updates here, no need to return the full item
    else
      render 'application/failure', errors: @app.errors
    end
  end

  def destroy
    @app = App.find(params[:id])
    if @app.destroy
      render 'application/success'
    else
      render 'application/failure'
    end
  end
end
