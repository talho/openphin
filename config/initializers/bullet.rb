file = RAILS_ROOT + "/config/bullet.yml"
bullet_enable = false
bullet_alert_enable = false
bullet_logger_enable = false
bullet_console_enable = false
bullet_growl_enable = false
bullet_rails_logger_enable = false
bullet_disable_browser_cache_enable = false
if File.exists?(file)
  config = YAML.load(IO.read(file))
  bullet_enable = config[RAILS_ENV]["enable"] if config[RAILS_ENV].has_key?("enable")
  bullet_alert_enable = config[RAILS_ENV]["alert_enable"] if config[RAILS_ENV].has_key?("alert_enable")
  bullet_logger_enable = config[RAILS_ENV]["logger_enable"] if config[RAILS_ENV].has_key?("logger_enable")
  bullet_console_enable = config[RAILS_ENV]["console_enable"] if config[RAILS_ENV].has_key?("console_enable")
  bullet_growl_enable = config[RAILS_ENV]["growl_enable"] if config[RAILS_ENV].has_key?("growl_enable")
  bullet_rails_logger_enable = config[RAILS_ENV]["rails_logger_enable"] if config[RAILS_ENV].has_key?("rails_logger_enable")
  bullet_disable_browser_cache_enable = config[RAILS_ENV]["disable_browser_cache_enable"] if config[RAILS_ENV].has_key?("disable_browser_cache_enable")
end

if bullet_enable
  Bullet.enable = bullet_enable
  Bullet.alert = bullet_alert_enable
  Bullet.bullet_logger = bullet_logger_enable
  Bullet.console = bullet_console_enable
  if bullet_growl_enable
    file = RAILS_ROOT + "/config/growl.yml"
    growl_host = "localhost"
    growl_password = nil
    enable = false
    if File.exists?(file)
      config = YAML.load(IO.read(file))
      growl_host = config[:host] if config.has_key?(:host)
      growl_password = config[:password] if config.has_key?(:password)
    end
    Bullet.growl_host = growl_host
    Bullet.growl_password = growl_password
  end
  Bullet.growl = bullet_growl_enable
  Bullet.rails_logger = bullet_rails_logger_enable
  Bullet.disable_browser_cache = bullet_disable_browser_cache_enable
end