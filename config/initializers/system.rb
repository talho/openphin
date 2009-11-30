file = RAILS_ROOT + "/config/system.yml"
OpenPHIN_config=HashWithIndifferentAccess.new
if File.exists?(file)
  OpenPHIN_config.merge! YAML.load(IO.read(file))
end

HoptoadNotifier.configure do |config|
  config.environment_filters << 'rack-bug.*'
  config.api_key = OpenPHIN_config[:hoptoad_api_key] unless OpenPHIN_config[:hoptoad_api_key].blank?
end
