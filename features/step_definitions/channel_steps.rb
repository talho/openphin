Given 'I created the channel "$name"' do |name|
  When 'I follow "New Channel"'
  And %Q|I fill in "Name" with "#{name}"|
  And 'I press "Create"'
  
  Then 'I should see "Successfully created the channel"'
  And %Q|I should see "#{name}"|
end

When 'I fill out the channel invitation form with:' do |table|
  fill_in_audience_form table
end
