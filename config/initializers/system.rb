file = RAILS_ROOT + "/config/system.yml"
OpenPHIN_config={}
if File.exists?(file)
  OpenPHIN_config.merge! YAML.load(IO.read(file))
end
  