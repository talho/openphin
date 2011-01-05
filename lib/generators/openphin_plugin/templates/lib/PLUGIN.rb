# Require PLUGIN_NAME models
Dir[File.join(File.dirname(__FILE__), 'models', '*.rb')].each do |f|
  require f
end

# Add PLUGIN_NAME vendor/plugins/*/lib to LOAD_PATH
Dir[File.join(File.dirname(__FILE__), '../vendor/plugins/*/lib')].each do |path|
  $LOAD_PATH << path
end

# Require any submodule dependencies here
# For example, if this depended on open_flash_chart you would require init.rb as follows:
#   require File.join(File.dirname(__FILE__), '..', 'vendor', 'plugins', 'open_flash_chart', 'init.rb')

# Register the plugin expansion in the $expansion_list global variable
$expansion_list = [] unless defined?($expansion_list)
$expansion_list.push(:<%= singular_name %>) unless $expansion_list.index(:<%= singular_name %>)

# Register any required javascript or stylesheet files with the appropriate
# rails expansion helper
ActionView::Helpers::AssetTagHelper.register_javascript_expansion(
  :<%= singular_name %> => [
    # add any necessary javascripts like "<%= file_name %>/cool_js_stuff.js"
  ])
ActionView::Helpers::AssetTagHelper.register_stylesheet_expansion(
  :<%= singular_name %> => [
    # add any necessary stylesheets like "<%= file_name %>/cool_css_stuff.css"
  ])
