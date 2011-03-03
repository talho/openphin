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
    end

    @users.each do |user|
      # Make sure current_user has admin privileges over the user to be deleted
      if user.editable_by?(current_user)
        user.delayed_delete_by(current_user.email,request.remote_ip)
      else
        flash[:error] ||= ""
        flash[:error] += "User #{current_user.email} does not have permission to delete #{user.email}.<br>"
      end
    end
    respond_to do |format|
      format.html {
        flash[:notice] = "Users have been successfully deleted." if flash[:error].blank?
        redirect_to admin_role_requests_path
      }
      format.json { render :json => {:delete_result => flash[:error].blank?, :success => true} }
    end
  end
  
end

# if RAILS_ENV == "production" 
#   user.send_later(:delete_virtually_by,current_user.email,request.remote_ip)
# else
#   user.delete_virtually_by(current_user.email,request.remote_ip)
# end
# 

