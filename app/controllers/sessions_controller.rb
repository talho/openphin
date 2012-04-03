class SessionsController < Clearance::SessionsController
  def create
    @user = authenticate(params)
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
      end
    end
  end

end
