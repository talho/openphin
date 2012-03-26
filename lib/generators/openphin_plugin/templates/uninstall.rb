parent_lib_dir = File.join(Rails.root.to_s, "lib")
[ "workers" ].each { |lib_subdir|
  target = File.join(parent_lib_dir, lib_subdir, "<%= file_name %>")
  File.unlink(target) if File.exists?(target)
}

target = "#{Rails.root.to_s}/vendor/plugins/<%= file_name %>/spec/spec_helper.rb"
File.unlink(target) if File.exists?(target)

parent_public_dir = File.join(Rails.root.to_s, "public")
[ "javascripts", "stylesheets" ].each { |public_subdir|
  target = File.join(parent_public_dir, public_subdir, "<%= file_name %>")
  File.unlink(target) if File.exists?(target)
}
