When 'I acknowledge the phone message for "$title"' do |title|
  a = Alert.find_by_title(title).alert_attempts.first
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
  When "delayed jobs are processed"
  # Reverse here to ensure we're looking at the newest emails first.
  # Otherwise, this will run into issues if earlier emails are sent to the same person.
  # if row = table.rows_hash.detect{|row| row.key =~ /subject/}
  #   email = ActionMailer::Base.deliveries.reverse.detect {|email| email.to.include?(email_address) && email.subject =~ /#{Regexp.escape(row.value)}/}
  # else
  if ActionMailer::Base.deliveries.reverse.detect.first.to.blank?
    email = ActionMailer::Base.deliveries.reverse.detect {|email| email.bcc.include?(email_address)}
  else
    email = ActionMailer::Base.deliveries.reverse.detect {|email| email.to.include?(email_address)}
  end
  # end
  email.should_not be_nil
  
  table.rows_hash.each do |field, value|
    case field
    when /subject/
      email.subject.should =~ /#{Regexp.escape(value)}/
    when /body contains alert acknowledgment link/
      attempt = User.find_by_email(email_address).alert_attempts.last
      email.body.should contain(acknowledge_alert_url(attempt, :host => HOST))
    when /body does not contain alert acknowledgment link/
      attempt = User.find_by_email(email_address).alert_attempts.last
      email.body.should_not contain(acknowledge_alert_url(attempt, :host => HOST))
    when /body contains/
      email.body.should =~ /#{Regexp.escape(value)}/
    when /body does not contain/
      email.body.should_not =~ /#{Regexp.escape(value)}/
    when /attachments/
      value.split(',').map { |m| email.attachments.map(&:original_filename).include? m }
    else
      raise "The field #{field} is not supported, please update this step if you intended to use it."
    end
  end
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
    
  emails = ActionMailer::Base.deliveries

  recipients.each do |user|
    if ActionMailer::Base.deliveries.reverse.detect.first.to.blank?
      email = ActionMailer::Base.deliveries.reverse.detect {|email| email.bcc.include?(user.email)}
    else
      email = ActionMailer::Base.deliveries.reverse.detect {|email| email.to.include?(user.email)}
    end
    email.should_not be_nil
    
    table.rows.each do |row|
      field, value = row.first, row.last
      case field
      when /subject/
        email.subject.should == value
      when /body contains/
        email.body.should =~ /#{Regexp.escape(value)}/
      when /body does not contain/
        email.body.should_not =~ /#{Regexp.escape(value)}/
      else
        raise "The field #{field} is not supported, please update this step if you intended to use it."
      end
    end
  end
end

Then '"$email" should not receive an email' do |email|
  When "delayed jobs are processed"
  if ActionMailer::Base.deliveries.detect.first.blank?
    email = nil
  else
    if ActionMailer::Base.deliveries.detect.first.to.blank?
      if ActionMailer::Base.deliveries.detect.first.bcc.blank?
        email = nil
      else
        email = ActionMailer::Base.deliveries.detect {|email| email.bcc.include?(email)}
      end
    else
      email = ActionMailer::Base.deliveries.detect {|email| email.to.include?(email)}
    end
  end
  email.should be_nil
end

Then '"$email" should not receive an email with the subject "$subject"' do |email, subject|
  When "delayed jobs are processed"
  if ActionMailer::Base.deliveries.detect.first.to.blank?
    email = ActionMailer::Base.deliveries.detect {|email| email.bcc.include?(email) && email.subject.include?(subject)}
  else
    email = ActionMailer::Base.deliveries.detect {|email| email.to.include?(email) && email.subject.include?(subject)}
  end
  email.should be_nil
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