class AlertMailer < ActionMailer::Base
  
  def alert(alert, user, device)
    recipients "#{user.name} <#{device.options[:email_address]}>"
    # TODO: should this show their job title instead of their role?
    # If role, which one?
    unless alert.author.nil? || alert.author.display_name.strip.blank?
      from "\"#{alert.author.display_name}\" <#{alert.author.email}>"
      headers "return-path" => alert.author.email
    else
      from DO_NOT_REPLY
    end
    severity = "#{alert.severity}"
    status = " #{alert.status}" if alert.status.downcase != "actual"
    subject "Health Alert \"#{alert.title}\""
    body :alert => alert, :alert_attempt => user.alert_attempts.find_by_alert_id(alert.id)
    if !alert.message_recording_file_name.blank?
      attachment alert.message_recording.content_type do |a|
        a.body = File.read(alert.message_recording.path)
        a.filename = alert.message_recording_file_name
      end
    end
  end
  
  def batch_alert(alert, users)
    bcc users
    # TODO: should this show their job title instead of their role?
    # If role, which one?
    unless alert.author.nil? || alert.author.display_name.strip.blank?
      from "\"#{alert.author.display_name}\" <#{alert.author.email}>"
      headers "return-path" => alert.author.email
    else
      from DO_NOT_REPLY
    end
    severity = "#{alert.severity}"
    status = " #{alert.status}" if alert.status.downcase != "actual"
    subject "Health Alert \"#{alert.title}\""
    body :alert => alert
    if !alert.message_recording_file_name.blank?
      attachment alert.message_recording.content_type do |a|
        a.body = File.read(alert.message_recording.path)
        a.filename = alert.message_recording_file_name
      end
    end
  end
  
end