if File.exists?(file = File.join(Rails.root, "/config/bullet.yml"))
  YAML.load(IO.read(file))[Rails.env].each do |method, value|
    Bullet.send(method.sub(/_enable$/, '') + "=", value)
  end
end

if Bullet.growl && File.exists?(growl = File.join(Rails.root, "/config/growl.yml"))
  growl = {:host => 'localhost'}.merge YAML.load(IO.read(growl)).symbolize_keys
  Bullet.growl_host = growl[:host] if defined? Bullet.growl_host
  Bullet.growl_password = growl[:password]
end
