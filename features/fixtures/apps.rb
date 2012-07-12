
App.find_or_create_by_name('system')
App.find_or_create_by_name('phin') do |phin|
  phin.is_default = true
  phin.about_label = 'About'
end
