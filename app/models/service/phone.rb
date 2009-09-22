require 'nokogiri'

class Service::Phone < Service::Base
  load_configuration_file RAILS_ROOT+"/config/swn.yml"

  def self.deliver_alert(alert, user, config=Service::Phone.configuration)
    initialize_fake_delivery(config) if config.fake_delivery?
    response = SWN.new(alert, config, [user])
    SWN::NotificationResponse.build(response,alert)
  end

    
  def self.batch_deliver_alert(alert, config=Service::Phone.configuration)
    initialize_fake_delivery(config) if config.fake_delivery?
    users = alert.alert_attempts.with_device("Device::PhoneDevice").map{ |aa| aa.user }
    response = SWN.new(alert, config, users).batch_deliver
    SWN::NotificationResponse.build(response,alert)
  end

  class << self
    private
    
    # Overwrites TFCC.deliver to push message onto 
    # Service::Phone.deliveries.
    def initialize_fake_delivery(config) # :nodoc:
      SWN.instance_eval do
        define_method(:perform_delivery) do |body|
          Service::Phone.deliveries << OpenStruct.new(:body => body)
          config.options[:default_response] ||= "200 OK"
        end
      end
    end
  end
  
  class SWN
    class Dialer
      include HTTParty
      
      def initialize(url, username, password)
        @url, @username, @password = url, username, password
      end
      
      def deliver(body)
        PHONE_LOGGER.info "Sending alert at #{Time.now}"
        response = self.class.post(@url, 
          :body => body, 
          :basic_auth => {:username => @username, :password => @password},
          :headers => { 'Content-Type' => (body =~/MIME_boundary/ ? "text/xml" : 'Multipart/Related; boundary=MIME_boundary; type=text/xml;'),
              'Accept' => 'text/xml/html', 
              'SOAPAction' => "\"http://www.sendwordnow.com/notification/sendNotification\""})
        PHONE_LOGGER.info "21CC Response:\n#{response}\n\n"
        return response
      end
    end

    class NotificationResultsRequest
      include HTTParty

      def self.add_header(xml)
        xml.tag!("soap-env:Header") do
          xml.AuthCredentials :xmlns => "http://www.sendwordnow.com/notification" do
            xml.username @username
            xml.password @password
          end
        end
      end
      def add_header(xml)
        self.add_header(xml)
      end
      
      def self.build(notification_result, options)
        @url, @username, @password  = options['url'], options['username'], options['password']

        body = ""
        xml = Builder::XmlMarkup.new :target => body, :indent => 2
        xsi = "xmlns:xsi".to_sym
        xsd = "xmlns:xsd".to_sym
        soapenv = "xmlns:soap-env".to_sym
        soapenc = "xmlns:soap-enc".to_sym
        xml.tag!("soap-env:Envelope", xsi => "http://www.w3.org/2001/XMLSchema-instance", xsd => "http://www.w3.org/2001/XMLSchema",
          soapenv => "http://schemas.xmlsoap.org/soap/envelope/", soapenc => "http://schemas.xmlsoap.org/soap/encoding/") do
          add_header xml
          xml.tag!("soap-env:Body") do
            xml.swn(:getNotificationResults, :xmlns => "http://www.sendwordnow.notification") do
              xml.swn(:pNotificationID, notification_result.alert.distribution_id)
            end

          end
        end

        PHONE_LOGGER.info "Sending activation detail request at #{Time.now}"
        PHONE_LOGGER.info "Request: #{body}"
        response = self.post(@url,
          :body => body,
          :basic_auth => {:username => @username, :password => @password},
          :headers => { 'Content-Type' => 'text/xml', 'Accept' => 'text/xml/html', 'SOAPAction' => "\"http://www.sendwordnow.com/notification/sendNotification\""})
        PHONE_LOGGER.info "21CC Response:\n#{response}\n\n"
        return response
      end


    end
    
    class NotificationResponse < ActiveRecord::Base
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

    def initialize(alert, config, users)
      @alert, @config, @users = alert, config, users
    end

    def deliver
      PHONE_LOGGER.info <<-EOT.gsub(/^\s+/, '')
        |Building alert message:
        |  alert: #{@alert.id}
        |  user_ids: #{@users.map(&:id).inspect}
        |  config: #{@config.options.inspect}
      EOT
      
      body = Service::SWN::Phone::Alert.new(
        :alert => @alert, 
        :users => @users,
        :username => @config['username'],
        :password => @config['password'],
        :retry_duration => @config['retry_duration']
      ).build!

      perform_delivery body
    end
    
    def batch_deliver
     PHONE_LOGGER.info <<-EOT.gsub(/^\s+/, '')
        |Building alert message:
        |  alert: #{@alert.id}
        |  config: #{@config.options.inspect}
      EOT
      
      body = Service::SWN::Phone::Alert.new(
        :alert => @alert, 
        :users => @users,
        :username => @config['username'],
        :password => @config['password'],
        :retry_duration => @config['retry_duration']
      ).build!

      perform_delivery body
    end
    
    private
    
    def perform_delivery(body)
      Dialer.new(@config['url'], @config['username'], @config['password']).deliver(body)
    end

  end
  
end
