if File.exist?(doc_yml = RAILS_ROOT+"/config/dashboard.yml")
  dash_config = YAML.load(IO.read(doc_yml))
  APP_LOGO = dash_config["logo_image"]
  # Ext needs width and height for proper layout.  This code will automatically find the dimensions of a PNG.
  # If you wish to use a non-PNG logo, either add code for that filetype or manually set APP_LOGO_DIMENSIONS[width,height] 
  APP_LOGO_DIMENSIONS = IO.read(RAILS_ROOT + '/public' + APP_LOGO)[0x10..0x18].unpack('NN')
  HELP_EMAIL = dash_config["help_email"]
  ABOUT_BUTTON_URL = dash_config["about_button_url"]
  ABOUT_BUTTON_LABEL = dash_config["about_button_label"]
end