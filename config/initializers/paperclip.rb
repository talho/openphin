file = RAILS_ROOT + "/config/paperclip.yml"

if File.exists?(file)
  config = YAML.load(IO.read(file))
  if config.has_key?(:image_magick_path)
    Paperclip.options[:image_magick_path] = config[:image_magick_path]
  end
end
