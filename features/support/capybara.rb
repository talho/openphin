
Capybara.register_driver :selenium_with_firebug do |app|
  if File.exists?("#{Rails.root.to_s}/features/support/firebug.xpi")
    profile = Selenium::WebDriver::Firefox::Profile.new
    profile['extensions.firebug.currentVersion'] = '100.100.100'
    profile['extensions.firebug.console.enableSites'] = 'true'
    profile['extensions.firebug.script.enableSites'] = 'true'
    profile['extensions.firebug.net.enableSites'] = 'true'
    profile['extensions.firebug.allPagesActivation'] = 'on'
    profile.add_extension("#{Rails.root.to_s}/features/support/firebug.xpi")

    Capybara::Selenium::Driver.new(app, { :browser => :firefox, :profile => profile, :resynchronize => true })
  else
    Capybara::Selenium::Driver.new(app, { :browser => :firefox, :resynchronize => true })
  end
end if ENV['HEADLESS'] == 'false' 

Capybara.register_driver :selenium_with_chrome do |app|
  Capybara::Selenium::Driver.new(app, { :browser => :chrome, :resynchronize => true })
end

Capybara.register_driver :selenium do |app|
  Capybara::Selenium::Driver.new(app, { :browser => :firefox, :resynchronize => true })
end