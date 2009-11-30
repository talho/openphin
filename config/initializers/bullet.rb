if File.exists?(file = Rails.root + "/config/bullet.yml")
  bullet_config = YAML.load(file)[Rails.env].symbolize_keys

  if Bullet.enable = bullet_config[:enable]
    Bullet.alert = bullet_config[:alert_enable]
    Bullet.bullet_logger = bullet_config[:logger_enable]
    Bullet.console = bullet_config[:console_enable]
    if Bullet.growl = bullet_config[:growl_enable]
      growl_config = {:host => 'localhost'}
      if File.exists?(growl = Rails.root + "/config/growl.yml")
        growl_config.merge! YAML.load(growl).symbolize_keys
      end
      Bullet.growl_host = growl_config[:host] if defined? Bullet.growl_host
      Bullet.growl_password = growl_config[:password]
    end
    Bullet.rails_logger = bullet_config[:rails_logger_enable]
    Bullet.disable_browser_cache = bullet_config[:disable_browser_cache_enable]
  end
end