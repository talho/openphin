When "I fill out the alert form with:" do |table|
  table.rows_hash.each do |key, value|
    case key
    when "People"
      value.split(',').each do |name| 
        user = Given "a user named #{name.strip}"
        fill_in 'alert_user_ids', :with => user.id
      end
    when 'Status', 'Severity'
      select value, :from => key
    when 'Acknowledge', 'Sensitive'
      id = "alert_#{key.parameterize('_')}"
      if value == '<unchecked>'
        uncheck id
      else
        check id
      end
    when 'Communication methods'
      check value
    when /Jurisdiction[s]?/
      value.split(',').each {|item| select item.strip, :from => 'alert_jurisdiction_ids' }
    when /Role[s]?/
      value.split(',').each {|item| select item.strip, :from => 'alert_role_ids' }
    when /Organization[s]?/
      value.split(',').each {|item| select item.strip, :from => 'alert_organization_ids' }
    else
      fill_in key, :with => value
    end
  end
end

Then 'I should see a preview of the message' do
  response.should have_tag('#preview')
end

Then 'I should see a preview of the message with:' do |table|
  table.rows_hash.each do |key, value|
    response.should have_tag(".#{key.parameterize('_')}", Regexp.new(value))
  end
end
