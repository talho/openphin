class Admin::UsersController < ApplicationController
  def new
    @user = User.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @user }
    end
  end
  
  def create
    assign_public_role_if_no_role_is_provided
    
    @user = User.new(params[:user])
    respond_to do |format|
      if @user.save
        # SignupMailer.deliver_confirmation(@user)
        # mark them confirmed
        # auto approve
        # send approval email
        flash[:notice] = 'The user has been successfully created.'
        format.html { redirect_to dashboard_path }
        format.xml  { render :xml => @user, :status => :created, :location => @user }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @user.errors, :status => :unprocessable_entity }
      end
    end
  end
  
end