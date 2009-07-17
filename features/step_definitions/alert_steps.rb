Given "an alert with:" do |table|
  attributes = table.rows_hash
  attributes['from_jurisdiction'] = Jurisdiction.find_by_name(attributes['from_jurisdiction'])
  Factory(:alert, attributes)
end

When "PhinMS delivers the message: $filename" do |filename|
  xml = File.read("#{Rails.root}/spec/fixtures/#{filename}")
  EDXL::Message.parse(xml)
end

When "I fill out the alert form with:" do |table|
  fill_in_alert_form table
end

When "I make changes to the alert form with:" do |table|
  table.rows_hash.each do |label, value|
    fill_in_alert_field label, value
  end
end

When 'I click "$link" on "$title"' do |link, title|
  within(".alert:contains('#{title}')") do
    click_link "View"
  end
end

Then 'I should see a preview of the message' do
  response.should have_tag('#preview')
end

Then 'I should see a preview of the message with:' do |table|
  table.rows_hash.each do |key, value|
    case key
    when /(Jurisdiction|Role|Organization|People)s?/
      value.split(',').each do |item|
        response.should have_tag(".#{key.parameterize('_')}", Regexp.new(item.strip))
      end
    else
      response.should have_tag(".#{key.parameterize('_')}", Regexp.new(value))
    end
  end
end

Then 'a foreign alert "$title" is sent to $name' do |title, name|
  When "delayed jobs are processed"
  cascade_alert = CascadeAlert.new(Alert.find_by_title(title))
  organization = Organization.find_by_name!(name)
  File.exist?(File.join(organization.phin_ms_queue, "#{cascade_alert.distribution_id}.edxl")).should be_true
end

Then 'no foreign alert "$title" is sent to $name' do |title, name|
  When "delayed jobs are processed"
  cascade_alert = CascadeAlert.new(Alert.find_by_title(title))
  organization = Organization.find_by_name!(name)
  File.exist?(File.join(organization.phin_ms_queue, "#{cascade_alert.distribution_id}.edxl")).should_not be_true
end

Then 'an alert exists with:' do |table|
  attrs = table.rows_hash
  alert = Alert.find(:first, :conditions => ["identifier = :identifier OR title = :title",
      {:identifier => attrs['identifier'], :title => attrs['title']}])
  attrs.each do |attr, value|
    case attr
    when 'from_jurisdiction'
      alert.from_jurisdiction.should == Jurisdiction.find_by_name!(value)
    when 'jurisdiction'
      alert.jurisdictions.should include(Jurisdiction.find_by_name!(value))
    when 'role'
      alert.roles.should include(Role.find_by_name(value))
    when 'from_organization'
      alert.from_organization.should == Organization.find_by_name!(value)
    when 'delivery_time'
      alert.delivery_time.should == value.to_i
    when 'sent_at'
      alert.sent_at.should be_close(Time.zone.parse(value), 1)
    when 'acknowledge'
      alert.acknowledge.should == (value == 'Yes')
    else
      alert.send(attr).should == value
    end
  end
end

Then 'I should see an alert titled "$title"' do |title|
  response.should have_tag('.alert .title', title)
end

Then 'I should not see an alert titled "$title"' do |title|
  response.should_not have_tag('.alert .title', title)
end

Then 'I can see the alert summary for "$title"' do |title|
  alert = Alert.find_by_title!(title)
  response.should have_tag('#?', dom_id(alert))
end