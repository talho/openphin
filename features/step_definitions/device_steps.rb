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

Then /^"([^\"]*)" should receive the email:$/ do |email_address, table|
  When "delayed jobs are processed"
  email = ActionMailer::Base.deliveries.detect {|email| email.to.include?(email_address) }
  email.should_not be_nil
  
  table.rows_hash.each do |field, value|
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
    email = ActionMailer::Base.deliveries.detect {|email| email.to.include?(user.email) }
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
  email = ActionMailer::Base.deliveries.detect {|email| email.to.include?(email) }
  email.should be_nil
end

Then "the following users should not receive any emails" do |table|
  headers = table.headers
  recipients = if headers.first == "roles"
    jurisdiction_name, role_name = headers.last.split("/").map(&:strip)
    jurisdiction = Jurisdiction.find_by_name!(jurisdiction_name)
    jurisdiction.users.with_role(role_name)
  end

  When "delayed jobs are processed"
  recipients.each do |user|
    email = ActionMailer::Base.deliveries.detect {|email| email.to.include?(user.email) }
    email.should be_nil
  end
end
