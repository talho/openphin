When "PhinMS delivers the message: $filename" do |filename|
  xml = File.read("#{Rails.root}/spec/fixtures/#{filename}")
  EDXL::Message.parse(xml)
end

When "I fill out the alert form with:" do |table|
  table.rows_hash.each do |key, value|
    case key
    when "People"
      value.split(',').each do |name| 
        user = Given "a user named #{name.strip}"
        fill_in 'alert_user_ids', :with => user.id.to_s
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
      select_multiple value.split(',').map(&:strip), :from => 'alert_jurisdiction_ids'
    when /Role[s]?/
      select_multiple value.split(',').map(&:strip), :from => 'alert_role_ids'
    when /Organization[s]?/
      select_multiple value.split(',').map(&:strip), :from => 'alert_organization_ids'
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
    case key
    when /[Jurisdiction|Role|Organization|People][s]?/
      value.split(',').each do |item|
        response.should have_tag(".#{key.parameterize('_')}", Regexp.new(item.strip))
      end
    else
      response.should have_tag(".#{key.parameterize('_')}", Regexp.new(value))
    end
  end
end

Then "a foreign alert is sent to $name" do |name|
  When "delayed jobs are processed"
  organization = Organization.find_by_name!(name)
  Dir.entries(organization.phin_ms_queue).size.should == 3 # ./ and ../ are always included
end

Then "no foreign alert is sent to $name" do |name|
  When "delayed jobs are processed"
  organization = Organization.find_by_name!(name)
  Dir.entries(organization.phin_ms_queue).size.should == 2 # ./ and ../ are always included
end
