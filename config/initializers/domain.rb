if File.exist?(doc_yml = RAILS_ROOT+"/config/domain.yml")
  DOMAIN_CONFIG = {}
  domain_config = YAML.load(IO.read(doc_yml))
  domain_config.each do  | portal |
    # Ext needs width and height for proper layout.  This code will automatically find the dimensions of a PNG.
    # If you wish to use a non-PNG logo, either add code for that filetype or manually set APP_LOGO_DIMENSIONS[width,height]
    portal['logo_image_dimensions'] = IO.read(RAILS_ROOT + '/public' + portal['logo_image'])[0x10..0x18].unpack('NN')
    DOMAIN_CONFIG[portal['domain']] = portal
  end
end
