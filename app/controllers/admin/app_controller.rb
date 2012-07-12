
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
    @app = App.new params[:app]
    if @app.save
      respond_with(@app)
    else
      respond_with @errors = @app.errors, status: 400 do |format|
        format.any { render 'application/failure'}
      end
    end
  end

  def edit
    redirect_to :admin_app
  end

  def update
    @app = App.find(params[:id])
    if @app.update_attributes params[:app]
      render 'application/success' # We're doing ajax, on-the-fly updates here, no need to return the full item
    else
      respond_with @errors = @app.errors, @app, status: 400 do |format|
        format.any { render 'application/failure'}
      end
    end
  end

  def destroy
    @app = App.find(params[:id])
    if @app.destroy
      render 'application/success'
    else
      respond_with @errors = @app.errors, status: 400 do |format|
        format.any { render 'application/failure'}
      end
    end
  end
  
  ## Special handler for uploads so as to be able to respond with a different sort of response
  def upload
    @app = App.find(params[:id])    
    if @app.update_attributes params[:app]
      render :json => {success: true, logo_url: @app.logo.url(:thumb), tiny_logo_url: @app.tiny_logo.url(:thumb)}
    else
      respond_with @errors = @app.errors, @app, status: 400 do |format|
        format.any { render 'application/failure'}
      end
    end
  end
end
