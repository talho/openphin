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

Then /^"([^\"]*)" should receive the email:$/ do |email, table|
  last_email = ActionMailer::Base.deliveries.last 
  last_email.should_not be_nil
  
  table.rows_hash.each do |field, value|
    case field
    when /subject/
      last_email.subject.should == value
    when /body contains/
      last_email.body.should =~ /#{Regexp.escape(value)}/
    else
      raise "The field #{field} is not supported, please update this step if you intended to use it."
    end
  end
end

