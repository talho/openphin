Given "an alert with:" do |table|
  attributes = table.rows_hash
  attributes['from_jurisdiction'] = Jurisdiction.find_by_name(attributes['from_jurisdiction']) unless attributes['from_jurisdiction'].blank?
  attributes['jurisdictions'] = attributes['jurisdictions'].split(',').map{|m| Jurisdiction.find_by_name(m.strip)} unless attributes['jurisdictions'].blank?
  attributes['organizations'] = attributes['organizations'].split(',').map{|m| Organization.find_by_name(m.strip)} unless attributes['organizations'].blank?
  attributes['roles'] = attributes['roles'].split(',').map{|m| Role.find_by_name(m.strip)} unless attributes['roles'].blank?
  if attributes['author'].blank?
    attributes['author_id'] = current_user.id unless current_user.nil?
  else
    attributes['author_id'] = User.find_by_display_name(attributes['author']).id
  end
  attributes.delete('author')
  Factory(:alert, attributes)
end

Given "a sent alert with:" do |table|
  a = Given "an alert with:", table
  a.deliver
  When "delayed jobs are processed"
end

Given "I've sent an alert with:" do |table|
  visit new_alert_path
  fill_in_alert_form table
  click_button "Preview Message"
  lambda { click_button "Send" }.should change(Alert, :count).by(1)
end

Given "\"$email_address\" has acknowledged the alert \"$title\"" do |email_address, title|
  u = User.find_by_email(email_address)
  aa = Factory(:alert_attempt, :alert => Alert.find_by_title(title), :user => u, :acknowledged_at => Time.zone.now)
  del = Factory(:delivery, :alert_attempt => aa, :device => u.devices.email.first)
end

Given "\"$email_address\" has not acknowledged the alert \"$title\"" do |email_address, title|
  u = User.find_by_email(email_address)
  aa = Factory(:alert_attempt, :alert => Alert.find_by_title(title), :user => u)
  del = Factory(:delivery, :alert_attempt => aa, :device => u.devices.email.first)
end

When "PhinMS delivers the message: $filename" do |filename|
  xml = File.read("#{Rails.root}/spec/fixtures/#{filename}")
  if(EDXL::MessageContainer.parse(xml).distribution_type == "Ack")
    EDXL::AckMessage.parse(xml)
  else
    EDXL::Message.parse(xml)
  end
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
        response.should have_tag(".#{key.parameterize('_')}", Regexp.new(Regexp.escape(item.strip)))
      end
    else
      response.should have_tag(".#{key.parameterize('_')}", Regexp.new(Regexp.escape(value)))
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
  File.exist?(File.join(organization.phin_ms_queue, "#{cascade_alert.distribution_id}.edxl")).should be_false
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

Then 'the alert "$alert_id" should be acknowledged' do |alert_id|
  alert = Alert.find_by_identifier(alert_id)
  alert.organizations.first.deliveries.sys_acknowledged?.should be_true
end

Then /^I can see the alert for "([^\"]*)" is (\d*)\% acknowledged$/ do |title,percent|
  response.should have_selector('.ackpercent', :content => percent)
end

Then /^I can see the jurisdiction alert acknowledgement rate for "([^\"]*)" in "([^\"]*)" is (\d*)%$/ do |alert_name, jurisdiction_name, percentage|
  response.should have_selector(".jur_ackpct") do |elm|
	  elm.should have_selector(".jurisdiction", :content => jurisdiction_name)
	  elm.should have_selector(".percentage", :content => percentage)
  end
end

Then /^I can see the device alert acknowledgement rate for "([^\"]*)" in "([^\"]*)" is (\d*)%$/ do |alert_name, device_type, percentage|
  response.should have_selector(".dev_ackpct") do |elm|
	  elm.should have_selector(".device_type", :content => device_type)
	  elm.should have_selector(".percentage", :content => percentage)
  end
end