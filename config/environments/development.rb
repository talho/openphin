require 'ipaddr'

# Settings specified here will take precedence over those in config/environment.rb

UPLOAD_BASE_URI = "http://localhost:3000"

# In the development environment your application's code is reloaded on
# every request.  This slows down response time but is perfect for development
# since you don't have to restart the webserver when you make code changes.
config.cache_classes = false

# Log error messages when you accidentally call methods on nil.
config.whiny_nils = true

# Show full error reports and disable caching
config.action_controller.consider_all_requests_local = true
config.action_view.debug_rjs                         = true
config.action_controller.perform_caching             = false
config.reload_plugins                                = true

#file = RAILS_ROOT + "/config/rack-bug.yml"
#rackbug_config=HashWithIndifferentAccess.new
#if File.exists?(file)
#  rackbug_config.merge! YAML.load(IO.read(file))
#end
#config.middleware.use("Rack::Bug",
#                      :ip_masks => (rackbug_config["ip_masks"].blank? ? [IPAddr.new("127.0.0.1"), IPAddr.new("10.0.0.0/8"), IPAddr.new("172.16.0.0/12"), IPAddr.new("192.168.0.0/16")] : rackbug_config["ip_masks"].split(',').map {|ip| IPAddr.new(ip)}),
#                      :password => rackbug_config["password"] || "secret",
#                      :secret_key => rackbug_config["secret_key"] || "epT5uCIchlsHCeR9dloOeAPG66PtHd9K8l0q9avitiaA/KUrY7DE52hD4yWY+8z1")

# Don't care if the mailer can't send
config.action_mailer.raise_delivery_errors = false
PHIN_PARTNER_OID="2.16.840.1.114222.4.3.2.2.3.770"
PHIN_APP_OID="1"
PHIN_ENV_OID="2"
PHIN_OID_ROOT="#{PHIN_PARTNER_OID}.#{PHIN_ENV_OID}.#{PHIN_APP_OID}"
