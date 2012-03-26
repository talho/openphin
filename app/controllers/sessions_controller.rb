class SessionsController < Clearance::SessionsController
#  layout "non_application"
  
#  skip_before_filter :login_required, :except => ["destroy"]
      
  def create
    @user = ::User.authenticate(params[:session][:email].downcase,
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
          sign_in(@user)
          format.html {
            redirect_back_or(url_after_create)
          }
          # iPhone app
          format.json {
            headers["Access-Control-Allow-Origin"] = "*"
            render :json => {:token => form_authenticity_token,
              :cookie => "#{ActionController::Base.session_options[:key]}=#{ActiveSupport::MessageVerifier.new(ActionController::Base.session_options[:secret], 'SHA1').generate(session.to_hash)}"
               }
          }
        else
          ::ClearanceMailer.confirmation(@user).deliver
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
    sign_out
#    flash_success_after_destroy
    redirect_to(url_after_destroy)
  end

end
