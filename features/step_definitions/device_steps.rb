
Given /^I have an? (.*) device$/ do |device_type|
  current_user.devices << Factory("#{device_type.downcase}_device")
  
end


When 'I acknowledge the phone message for "$title"' do |title|
  a = Alert.find_by_title(title).alert_attempts.first
  a.acknowledged_at = Time.zone.now
  a.save!
end

When '"$email" acknowledges the phone alert' do |email|
  a = User.find_by_email(email).alert_attempts.first
  a.acknowledged_at = Time.zone.now
  a.save!
end

Then /^"([^"]+). should have the communication device$/ do |email, table|
  user = User.find_by_email!(email)
  table.rows_hash.each do |type, value|
    case type
    when /Email/
      device = user.devices.email.detect{ |e| e.email_address == value }
      device.should_not be_nil
    else
      raise "The type '#{type}' is not supported, please update this step if you intended to use it"
    end
  end
end

Then /^"([^"]+). should not have the communication device$/ do |email, table|
  user = User.find_by_email!(email)
  table.rows_hash.each do |type, value|
    case type
    when /Email/
      device = user.devices.email.detect{ |e| e.email_address == value }
      device.should be_nil
    else
      raise "The type '#{type}' is not supported, please update this step if you intended to use it"
    end
  end
end

Then /^I should see in my list of devices$/ do |table|
  table.rows_hash.each do |type, value|
    case type
    when /Email/
      response.should have_selector('#devices .device_email_device', :content => value)
    else
      raise "The type '#{type}' is not supported, please update this step if you intended to use it"
    end
  end
end

Then /^"([^\"]*)" should receive the email:$/ do |email_address, table|
  find_email(email_address, table).should_not be_nil
end

Then /^"([^\"]*)" should receive the email with an alert attachment:$/ do |email_address, table|
  email = find_email(email_address, table)
  email.attachments.should_not be_nil
end

Then /^the following users should receive the email:$/ do |table|
  When "delayed jobs are processed"
  
  headers = table.headers
  recipients = if headers.first == "roles"
    jurisdiction_name, role_name = headers.last.split("/").map(&:strip)
    jurisdiction = Jurisdiction.find_by_name!(jurisdiction_name)
    jurisdiction.users.with_role(role_name)
  end
  
  recipients = headers.last.split(',').map{|u| User.find_by_email!(u.strip)} if headers.first == "People"
  
  recipients.each do |user|
    Then %Q{"#{user.email}" should receive the email:}, table
  end
end

Then '"$email" should not receive an email' do |email|
  find_email(email).should be_nil  
end

Then '"$email" should not receive an email with the subject "$subject"' do |email, subject|
  table = Cucumber::Ast::Table.new([['key','value'],['subject', subject]])
  find_email(email, table).should be_nil
end

Then "the following users should not receive any emails" do |table|
  headers = table.headers
  recipients = if headers.first == "roles"
    jurisdiction_name, role_name = headers.last.split("/").map(&:strip)
    jurisdiction = Jurisdiction.find_by_name!(jurisdiction_name)
    jurisdiction.users.with_role(role_name)
  elsif headers.first == "emails"
    headers.last.split(',').map(&:strip).map{|m| User.find_by_email!(m)}
  end
  
  recipients.each do |user|
    Then %Q{"#{user.email}" should not receive an email}
  end
end
  
Then 'I should have a phone device with the phone "$text"' do |text|
  device = current_user.devices.phone.detect{ |device| device.phone == text }
  device.phone.should_not be_nil
end
  
Then 'I should have a SMS device with the SMS number "$text"' do |text|
  device = current_user.devices.sms.detect{ |device| device.sms == text }
  device.sms.should_not be_nil
end

Then 'I should have a Fax device with the Fax number "$text"' do |text|
  device = current_user.devices.fax.detect{ |device| device.fax == text }
  device.fax.should_not be_nil
end

Then 'I should have a Blackberry device with the Blackberry number "$text"' do |text|
  device = current_user.devices.blackberry.detect{ |device| device.blackberry == text }
  device.blackberry.should_not be_nil
end

Then /^the following phone calls should be made:$/ do |table|
  table.hashes.each do |row|
    call = Service::Phone.deliveries.detect do |phone_call|
      xml = Nokogiri::XML(phone_call.body)
      if row["recording"].blank?
        message = (xml / 'ucsxml/request/activation/campaign/program/*/slot[@id="1"]').inner_text
        phone = (xml / "ucsxml/request/activation/campaign/audience/contact/*[@type='phone']").inner_text
        message == row["message"] && phone == row["phone"]
      else
        message = (xml / 'ucsxml/request/activation/campaign/program/*/slot[@id="1"]').inner_text
        phone = (xml / "ucsxml/request/activation/campaign/audience/contact/*[@type='phone']").inner_text
        recording = Base64.encode64(IO.read(Alert.find_by_message_recording_file_name(row["recording"]).message_recording.path))
        message == recording && phone == row["phone"]
      end
    end
    call.should_not be_nil
  end
end

Then /^the following SMS calls should be made:$/ do |table|
  table.hashes.each do |row|
    call = Service::SMS.deliveries.detect do |sms_call|
      xml = Nokogiri::XML(sms_call.body)
      message = (xml / 'ucsxml/request/activation/campaign/program/*/slot[@id="1"]').inner_text
      sms = (xml / "ucsxml/request/activation/campaign/audience/contact/*[@type='phone']").inner_text
      message == row["message"] && sms == row["sms"]
    end
    call.should_not be_nil
  end
end

Then /^the following Fax calls should be made:$/ do |table|
  table.hashes.each do |row|
    call = Service::Fax.deliveries.detect do |fax_call|
      xml = Nokogiri::XML(fax_call.body)
      message = (xml / 'ucsxml/request/activation/campaign/program/*/slot[@id="1"]').inner_text
      fax = (xml / "ucsxml/request/activation/campaign/audience/contact/*[@type='phone']").inner_text
      message == row["message"] && fax == row["fax"]
    end
    call.should_not be_nil
  end
end

Then /^the following Blackberry calls should be made:$/ do |table|
  table.hashes.each do |row|
    call = Service::Blackberry.deliveries.detect do |blackberry_call|
      xml = Nokogiri::XML(blackberry_call.body)
      body = xml.xpath('.//soap-env:Envelope/soap-env:Body')
      note = body.xpath('.//swn:sendNotification/swn:pSendNotificationInfo/swn:SendNotificationInfo', {'swn' => 'http://www.sendwordnow.com/notification'})
      message = note.xpath('.//swn:notification/swn:body', {'swn' => 'http://www.sendwordnow.com/notification'}).inner_text
      blackberry = note.xpath(".//swn:rcpts/*/swn:contactPnts/swn:contactPntInfo/swn:address", {'swn' => 'http://www.sendwordnow.com/notification'}).inner_text
      message == row["message"] && blackberry == "#{row['blackberry']}@blackberry.sendwordnow.com"
    end
    call.should_not be_nil
  end
end