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
  find_email(email, Cucumber::Ast::Table.new([['subject', subject]])).should be_nil
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


Then /^the following phone calls should be made:$/ do |table|
  table.hashes.each do |row|
    call = Service::Phone.deliveries.detect do |phone_call|
      xml = Nokogiri::XML(phone_call.body)
      if row["recording"].blank?
        message = (xml / 'ucsxml/request/activation/campaign/program/*/slot').inner_text
        phone = (xml / "ucsxml/request/activation/campaign/audience/contact/*[@type='phone']").inner_text
        message == row["message"] && phone == row["phone"]
      else
        message = (xml / 'ucsxml/request/activation/campaign/program/*/slot').inner_text
        phone = (xml / "ucsxml/request/activation/campaign/audience/contact/*[@type='phone']").inner_text
        recording = Base64.encode64(IO.read(Alert.find_by_message_recording_file_name(row["recording"]).message_recording.path))
        message == recording && phone == row["phone"]
      end
    end
    call.should_not be_nil
  end
end