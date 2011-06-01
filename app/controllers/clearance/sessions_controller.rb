class Clearance::SessionsController < ApplicationController
  unloadable

  protect_from_forgery :except => :create
  filter_parameter_logging :password
  layout "non_application"
  
  skip_before_filter :login_required, :except => ["destroy"]

  def new
    render :template => 'sessions/new'
  end

  def create
    @user = User.authenticate(params[:session][:email].downcase,
                                params[:session][:password])
    respond_to do |format|
      if @user.nil?
        format.html {
          flash_failure_after_create
          flash[:email_address] = params[:session][:email]
          render :template => 'sessions/new', :status => :unauthorized
        }
        # iPhone app
        format.json {render :nothing=>true, :status => :unauthorized}
      else
        if @user.email_confirmed?
          format.html {
            sign_in(@user)
            remember(@user) if remember?
            redirect_back_or(url_after_create)
          }
          # iPhone app
          format.json {
            sign_in(@user)
            remember(@user) if remember?
            headers["Access-Control-Allow-Origin"] = "*"
            render :json => {:token => form_authenticity_token,
              :cookie => "#{ActionController::Base.session_options[:key]}=#{ActiveSupport::MessageVerifier.new(ActionController::Base.session_options[:secret], 'SHA1').generate(session.to_hash)}"
               }
          }
        else
          SignupMailer.deliver_confirmation(@user)
          format.html {
            flash_notice_after_create
            redirect_to(new_session_url)
          }
          #iPhone app
          format.json {render :nothing=>true, :status => :unprocessable_entity}
        end
      end
    end
  end

  def destroy
    forget(current_user)
#    flash_success_after_destroy
    redirect_to(url_after_destroy)
  end

  private

  def flash_failure_after_create
    flash.now[:error] = translate(:bad_email_or_password,
      :scope   => [:clearance, :controllers, :sessions],
      :default => "Bad email or password.")
  end

  def flash_success_after_create
    flash[:completed] = translate(:signed_in, :default =>  "Signed in.")
  end

  def flash_notice_after_create
    flash[:notice] = translate(:unconfirmed_email,
      :scope   => [:clearance, :controllers, :sessions],
      :default => "Your account is unconfirmed. " <<
                  "Confirmation email will be resent.")
  end

  def url_after_create
    root_url
  end

  def flash_success_after_destroy
    flash[:completed] = translate(:signed_out, :default =>  "Signed out.")
  end

  def url_after_destroy
    new_session_url
  end
end
