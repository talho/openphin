require 'nokogiri'

class Service::Email < Service::Base
  load_configuration_file RAILS_ROOT+"/config/swn.yml"

  def self.deliver_alert(alert, user, config=Service::Email.configuration)
    initialize_fake_delivery(config) if config.fake_delivery?
    response = SWN.new(alert, config, [user]).deliver
    SWN::AlertNotificationResponse.build(response,alert)
  end


  def self.batch_deliver_alert(alert, config=Service::Email.configuration)
    initialize_fake_delivery(config) if config.fake_delivery?
    users = alert.alert_attempts.with_device("Device::EmailDevice").map{ |aa| aa.user }
    response = SWN.new(alert, config, users).batch_deliver
    SWN::AlertNotificationResponse.build(response,alert)
  end

  def self.deliver_invitation(invitation, config=Service::Email.configuration)
    initialize_fake_delivery(config) if config.fake_delivery?
    response = Service::SWN::Invitation.new(invitation, config, invitation.new_invitees).deliver
    response.nil? ? "" : "200 OK"
    #Service::SWN::Email::InvitationNotificationResponse.build(response, invitation)
  end

  def self.deliver_org_membership_notification(invitation, config=Service::Email.configuration)
    initialize_fake_delivery(config) if config.fake_delivery?
    response = Service::SWN::Invitation.new(invitation, config, invitation.registered_invitees).deliver_org_membership_notification
    response.nil? ? "" : "200 OK"
    #Service::SWN::Email::InvitationNotificationResponse.build(response, invitation)
  end

  class << self
    private

    # Overwrites SWN.deliver to push message onto
    # Service::Email.deliveries.
    def initialize_fake_delivery(config) # :nodoc:
      Service::SWN::Invitation.instance_eval do
        define_method(:perform_delivery) do |body|
          Service::Email.deliveries << OpenStruct.new(:body => body)
          config.options[:default_response] ||= "200 OK"
        end
      end
    end
  end

end
