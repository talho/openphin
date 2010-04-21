# Allow the metal piece to run in isolation
require(File.dirname(__FILE__) + "/../../config/environment") unless defined?(Rails)
require 'sinatra'
set :run => false, :environment => Rails.env
Ws = Sinatra::Application unless defined? Ws

helpers do

  def current_user
    @_user
  end
  def protected!
    response['WWW-Authenticate'] = %(Basic realm="OpenPHIN") and \
    throw(:halt, [401, "Not authorized\n"]) and \
    return unless authorized?
  end

  def authorized?
    @auth  ||=  Rack::Auth::Basic::Request.new(request.env)
    @_user ||= User.authenticate(@auth.credentials[0], @auth.credentials[1]) if @auth && @auth.provided? && @auth.credentials
  end

end

get "/ws/alerts" do
  debugger
  protected!
  current_user.recent_alerts.to_json(
      :include => {
        :author => {:methods => :display_name, :only => [:first_name, :last_name, :email]},
        :from_jurisdiction => {:only => :name}}
      )
end

post "/ws/alert/:distribution_id/ack" do
  protected!
  attempt=current_user.alert_attempts.find(:first, :joins => :alert, :conditions => ["alerts.distribution_id = ?", params[:distribution_id]])
  if attempt
    if attempt.acknowledged?
      {:success => "Alert has already been acknowledged"}.to_json
    else
      attempt.acknowledge! "Device::ConsoleDevice"
      {:success => "Alert acknowledged"}.to_json
    end

  else
    {:error => "Unable to acknowledge alert"}.to_json
  end
end