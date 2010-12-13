class Admin::UsersDeleteController < ApplicationController
  before_filter :admin_required
  app_toolbar "admin"

  def new
  end
  
  def create
    params[:users][:user_ids] -= [current_user.id.to_s]   # avoid current user deleting self
    @users = User.find_all_by_id(params[:users][:user_ids])
    if @users.empty?
      flash[:error] = "A valid user was not selected."
      redirect_to :back
      return
    else
      @users.each do |user|
        user.delayed_delete_by(current_user.email,request.remote_ip)
      end
    end
    respond_to do |format|
      format.html {
        flash[:notice] = "Users have been successfully deleted." if flash[:errors].blank?
        redirect_to admin_role_requests_path
      }
      format.json { render :json => {:delete_result => flash[:errors].blank?, :success => true} }
    end
  end
  
end

# if RAILS_ENV == "production" 
#   user.send_later(:delete_virtually_by,current_user.email,request.remote_ip)
# else
#   user.delete_virtually_by(current_user.email,request.remote_ip)
# end
# 

