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
      case @user_batch.valid
        when "bad-email"
          flash[:error] = "Authentication error, please contact your administrator."
        when "bad-jurisdiction"
          flash[:error] = "You do not have permission to add users to that jurisdiction."
        when "bad-file"
          flash[:error] = "Problem with file.  Please check that it is valid CSV."
        else        
          if @user_batch.save
            flash[:notice] = 'The user batch has been successfully submitted.' + 
            '<br /> You will receive an E-Mail if there is a problem processing your request.'
          else
            flash[:error] = 'There was an error. No users were created.'
          end
      end
      redirect_to new_user_batch_path
    end
  end
  
end

