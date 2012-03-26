file = Rails.root.to_s+ "/config/paperclip.yml"

if File.exists?(file)
  config = YAML.load(IO.read(file))
  if config.has_key?(:command_path)
    Paperclip.options[:command_path] = config[:command_path]
  end
end
