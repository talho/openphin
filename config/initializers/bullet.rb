if File.exists?(file = Rails.root + "/config/bullet.yml")
  YAML.load(file)[Rails.env].each do |method, value|
    Bullet.send(method.sub(/_enable$/, ''), value)
  end
end

if Bullet.growl && File.exists?(growl = Rails.root + "/config/growl.yml")
  growl = {:host => 'localhost'}.merge YAML.load(growl).symbolize_keys
  Bullet.growl_host = growl[:host] if defined? Bullet.growl_host
  Bullet.growl_password = growl[:password]
end
