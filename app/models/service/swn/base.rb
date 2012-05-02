class Service::Swn::Base
  extend PropertyObject::ClassMethods
  include PropertyObject::InstanceMethods

  class Configuration
    FAKE_DELIVERY_METHOD = :test
    DEFAULT_DELIVERY_METHOD = :deliver

    attr_accessor :options
    
    def initialize
      @options = Hash.new
    end

    def fake_delivery?
      options["delivery_method"] == "test"
    end

    def to_hash
      options.dup
    end

    delegate :[], :to => :options
    delegate :[]=, :to => :options
  end

  # =================
  # = CLASS METHODS =
  # =================

  def self.configuration
    #configuration on a per-class basis
    @configuration||={}
    @configuration[self.name] ||= Configuration.new
  end

  def self.load_configuration_file(file)
    configuration.options = configuration.options.merge! YAML.load(IO.read(file))[Rails.env]
    if configuration.fake_delivery?
      def self.deliveries
        @deliveries ||= []
      end

      def self.clearDeliveries
        @deliveries = []
      end
    end
  end

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
      xml = ::Builder::XmlMarkup.new :target => body, :indent => 2
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
    Dialer.new(self.class.configuration['url'], self.class.configuration['username'], self.class.configuration['password']).deliver(body)
  end

end