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
    @auth ||=  Rack::Auth::Basic::Request.new(request.env)
    @_user ||= User.authenticate(@auth.credentials[0], @auth.credentials[1]) if @auth && @auth.provided? && @auth.credentials
  end

end

get "/ws/alerts" do
  protected!
  current_user.recent.to_json
end