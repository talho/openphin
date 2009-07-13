When 'I signup for an account with the following info:' do |table|
  visit new_phin_person_path
  table.hashes.each do |hash|
    case hash['field']
    when 'E-mail', 'Password', 'Password confirmation', 'First name', 'Last name', 'Preferred name'
      fill_in hash['field'], :with => hash['value']
    when 'What County', 'Preferred language'
      select hash['value'], :from => hash['field']
    else
      raise "Unknown field: #{hash['field']}"
    end
  end
  
  click_button 'Save'
end