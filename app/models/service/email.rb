require 'nokogiri'

class Service::Email < Service::Base
  load_configuration_file RAILS_ROOT+"/config/swn.yml"
  load_configuration_file RAILS_ROOT+"/config/email.yml"

  def self.deliver_alert(alert, user, config=Service::Email.configuration)
    initialize_fake_delivery(config) if config.fake_delivery?
    response = SWN.new(alert, config, [user]).deliver
    SWN::AlertNotificationResponse.build(response,alert)
  end


  def self.batch_deliver_alert(alert, config=Service::Email.configuration)
    if Service::Email.configuration["alert"] == "SWN"
      initialize_fake_delivery(config) if config.fake_delivery?
      users = alert.alert_attempts.with_device("Device::EmailDevice").map{ |aa| aa.user }
      response = Service::SWN::Alert.new(alert, config, users).deliver
      response.nil? ? "" : "200 OK"
      #SWN::AlertNotificationResponse.build(response,alert)
    else
      users = alert.unacknowledged_users.map(&:formatted_email)
      users.batch_process(50) do |emails|
        begin
          AlertMailer.deliver_batch_alert(alert, emails) unless alert.alert_attempts.nil?
        rescue Net::SMTPSyntaxError => e
          logger.error "Error mailing alert to the following recipients: #{emails.join(",")}\nException:#{e}"
          logger.error "Attempting individual resends"
          emails.each do |eml|
            begin
              AlertMailer.deliver_batch_alert(alert, eml)
              logger.error "Resent to #{eml}"
            rescue
              logger.error "Unable to resend to #{eml}"
            end
          end
        rescue
          logger.error e
        end
      end
    end
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
      Service::SWN::Alert.instance_eval do
        define_method(:perform_delivery) do |body|
          Service::Email.deliveries << OpenStruct.new(:body => body)
          config.options[:default_response] ||= "200 OK"
        end
      end

      Service::SWN::Invitation.instance_eval do
        define_method(:perform_delivery) do |body|
          Service::Email.deliveries << OpenStruct.new(:body => body)
          config.options[:default_response] ||= "200 OK"
        end
      end
    end
  end

end
