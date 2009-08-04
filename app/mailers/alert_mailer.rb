class AlertMailer < ActionMailer::Base
  
  def alert(alert, user, device)
    role_membership = alert.author.role_memberships.first
    recipients "#{user.name} <#{device.options[:email_address]}>"
    # TODO: should this show their job title instead of their role?
    # If role, which one?
    from DO_NOT_REPLY
    subject "#{alert.severity} Health Alert from #{role_membership.jurisdiction.name} : #{alert.author.name} : #{role_membership.role.name}"
    body :alert => alert, :alert_attempt => user.alert_attempts.find_by_alert_id(alert.id)
    if !alert.message_recording_file_name.blank?
      attachment alert.message_recording.content_type do |a|
        a.body = File.read(alert.message_recording.path)
        a.filename = alert.message_recording_file_name
      end
    end
  end
  
end