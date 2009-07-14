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

Then '"$email" should have the "$role" role for "$jurisdiction"' do |email, role, jurisdiction|
  p=PhinPerson.find_by_email!(email)
  j = PhinJurisdiction.find_by_name!(jurisdiction)
  r = PhinRole.find_by_name!(role)
  m = p.role_memberships.find_by_phin_role_id_and_phin_jurisdiction_id(r.id, j.id)
  m.should_not be_nil
end