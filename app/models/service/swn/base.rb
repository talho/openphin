class Service::SWN::Base
  extend PropertyObject::ClassMethods
  include PropertyObject::InstanceMethods

  class Dialer
    include HTTParty

    def initialize(url, username, password)
      @url, @username, @password = url, username, password
    end

    def deliver(body)
      SWN_LOGGER.info "Sending request at #{Time.now}"
      response = self.class.post(@url,
        :body => body,
        :basic_auth => {:username => @username, :password => @password},
        :headers => { 'Content-Type' => (body =~/MIME_boundary/ ? "text/xml" : 'Multipart/Related; boundary=MIME_boundary; type=text/xml;'),
            'Accept' => 'text/xml/html',
            'SOAPAction' => "\"http://www.sendwordnow.com/notification/sendNotification\""})
      SWN_LOGGER.info "SWN Response:\n#{response}\n\n"
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

    def self.build(notification_id, options)
      @url, @username, @password  = options['url'], options['username'], options['password']

      body = ""
      xml = Builder::XmlMarkup.new :target => body, :indent => 2
      xsi = "xmlns:xsi".to_sym
      xsd = "xmlns:xsd".to_sym
      swn = "xmlns:swn".to_sym
      soapenv = "xmlns:soap-env".to_sym
      soapenc = "xmlns:soap-enc".to_sym
      xml.tag!("soap-env:Envelope", xsi => "http://www.w3.org/2001/XMLSchema-instance", xsd => "http://www.w3.org/2001/XMLSchema",
        soapenv => "http://schemas.xmlsoap.org/soap/envelope/", soapenc => "http://schemas.xmlsoap.org/soap/encoding/") do
        add_header xml
        xml.tag!("soap-env:Body") do
          xml.swn(:getNotificationResults, :"xmlns:swn" => "http://www.sendwordnow.com/notification") do
            xml.swn(:pNotificationID, notification_id)
          end

        end
      end

      SWN_LOGGER.info "Sending activation detail request at #{Time.now}"
      SWN_LOGGER.info "Request: #{body}"
      response = self.post(@url,
        :body => body,
        :basic_auth => {:username => @username, :password => @password},
        :headers => { 'Content-Type' => 'text/xml', 'Accept' => 'text/xml/html', 'SOAPAction' => "\"http://www.sendwordnow.com/notification/getNotificationResults\""})
      SWN_LOGGER.info "SWN Response:\n#{response}\n\n"
      return response
    end

  end

  private

  def perform_delivery(body)
    Dialer.new(@config['url'], @config['username'], @config['password']).deliver(body)
  end

end