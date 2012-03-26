if File.exists?(file = File.join(Rails.root.to_s, "/config/bullet.yml"))
  YAML.load(IO.read(file))[Rails.env].each do |method, value|
    Bullet.send(method.sub(/_enable$/, '') + "=", value)
  end
end