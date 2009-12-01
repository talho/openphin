class Clearance::PasswordsController < ApplicationController
  unloadable

  skip_before_filter :login_required, :only => [:new, :create, :edit, :update]
  
  filter_parameter_logging :password, :password_confirmation
  layout "non_application"

  def new
    render :template => 'passwords/new'
  end

  def create
    if user = ::User.find_by_email(params[:password][:email])
      user.forgot_password!
      ::ClearanceMailer.deliver_change_password user
      flash_notice_after_create
      redirect_to(url_after_create)
    else
      flash_failure_after_create
      render :template => 'passwords/new'
    end
  end

  def edit
    if params[:token].blank?
      flash_for_missing_token
      redirect_to new_session_path
    else
      unless @user = ::User.find_by_id_and_token(params[:user_id], params[:token])
        flash_for_incorrect_token
        redirect_to new_session_path
      else
        render :template => 'passwords/edit'
      end
    end
  end

  def update
    if params[:token].blank?
      flash_for_missing_token
    else
      unless @user = ::User.find_by_id_and_token(params[:user_id], params[:token])
        flash_for_incorrect_token
      else
        if @user.update_password(params[:user][:password],
                                 params[:user][:password_confirmation])
          @user.confirm_email!
          sign_in(@user)
          flash_success_after_update
          redirect_to(url_after_update)
        else
          render :template => 'passwords/edit'
        end
      end
    end
  end

private

  def flash_for_incorrect_token
    flash[:error] = translate(:password_reset_incorrect_token,
      :scope   => [:clearance, :controllers, :passwords],
      :default => "The token from your link is incorrect. " <<
                  "Try re-pasting the edit invite link into your browser address bar.")
  end

  def flash_for_missing_token
    flash[:error] = translate(:password_reset_missing_token,
      :scope   => [:clearance, :controllers, :passwords],
      :default => "The token from your link is missing. " <<
                  "Try re-pasting the edit invite link into your browser address bar.")
  end

  def flash_notice_after_create
    flash[:notice] = translate(:deliver_change_password,
      :scope   => [:clearance, :controllers, :passwords],
      :default => "You will receive an email within the next few minutes. " <<
                  "It contains instructions for changing your password.")
  end

  def flash_failure_after_create
    flash.now[:error] = translate(:unknown_email,
      :scope   => [:clearance, :controllers, :passwords],
      :default => "Unknown email.")
  end

  def url_after_create
    new_session_url
  end

  def flash_success_after_update
    flash[:completed] = translate(:signed_in, :default => "Signed in.")
  end

  def url_after_update
    root_url
  end
end
