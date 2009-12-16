class Admin::UserBatchController < ApplicationController
  before_filter :admin_required
  app_toolbar "admin"

  def new
    @jurisdictions = current_user.jurisdictions.admin.find(:all, :select => "DISTINCT name", :order => "name")
  end
  
  def create
   if request.post?
      @user_batch = UserBatch.new params[:user_batch]
      @user_batch.email = current_user.email
      if @user_batch.valid?
        if @user_batch.save
          flash[:notice] = 'The user batch has been successfully submitted.'
          redirect_to admin_role_requests_path
        else
          flash[:error] = 'The user batch was not created.'
          redirect_to admin_role_requests_path
        end
      end
    end
  end
  
end

