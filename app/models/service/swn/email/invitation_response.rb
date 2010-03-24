class Service::SWN::Email::InvitationNotificationResponse < ActiveRecord::Base
  set_table_name "swn_notification_response"
  belongs_to :alert

  named_scope :acknowledge, :joins => :alert, :conditions => ['alerts.acknowledge = ?', true]
  named_scope :active, :joins => :alert, :conditions => ['UNIX_TIMESTAMP(alerts.created_at) + (alerts.delivery_time * 60) > UNIX_TIMESTAMP(UTC_TIMESTAMP())']

  def self.build(response, alert)
    if !alert.blank?
      if !response.blank? && !response['soap:Envelope'].blank? && !response['soap:Envelope']['soap:Header'].blank?
        msg_id = response['soap:Envelope']['soap:Header']['wsa:MessageID']
        self.create!(:alert => alert, :message_id => msg_id)
      else
        self.create!(:alert => alert)
      end
    end
  end
end
