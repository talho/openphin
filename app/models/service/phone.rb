class Service::Phone < Service::Base
  CONFIG = YAML.load IO.read(RAILS_ROOT+"/config/phone.yml")
  
  def self.deliver_alert(alert, user, device)
    new(alert, user, device).deliver
  end
  
  def initialize(alert, user, device, config=Service::Phone.configuration)
    @alert = alert
    @user = user
    @device = device
    initialize_fake_delivery(config) if config.fake_delivery?
    TwentyFirstCenturyCommunications.configuration = CONFIG[RAILS_ENV]
  end
  
  def deliver
    TwentyFirstCenturyCommunications.new(@alert, @user, @device).deliver
  end
  
  private
  
  # Overwrites TwentyFirstCenturyCommunications.deliver to push message onto 
  # Service::Phone.deliveries.
  def initialize_fake_delivery(config) # :nodoc:
    TwentyFirstCenturyCommunications.instance_eval do
      define_method(:perform_delivery) do |body|
        Service::Phone.deliveries << OpenStruct.new(:body => body)
        config.options[:default_response] ||= "200 OK"
      end
    end
  end
  
  class TwentyFirstCenturyCommunications
    class << self
      attr_accessor :configuration
    end
    
    %w(username password url client_id user_id).each do |field|
      define_method(field) do
        self.class.configuration[field]
      end
    end
    
    def retry_duration
      eval(self.class.configuration['retry_duration'])
    end
    
    class Dialer
      require 'httparty'
      include ::HTTParty
      
      def initialize(url, username, password)
        @url = url
        @username = username
        @password = password
      end
      
      def deliver(body)
        msg = "#{Time.now} - delivering #{body} to 21CC"
        PHONE_LOGGER.info "#{msg}\n#{body}\n"
        Rails.logger.info msg
        response = self.class.post(@url, 
          :body => body, 
          :basic_auth => {:username => @username, :password => @password},
          :headers => { 'Content-Type' => 'text/xml', 'Accept' => 'text/xml/html'})
        PHONE_LOGGER.info "---------- RESPONSE ---------\n#{response}"
      end
    end
    
    def initialize(alert, user, device)
      @alert = alert
      @user = user
      @device = device
    end
    
    def deliver
      body = ""
      xml = Builder::XmlMarkup.new :target => body, :indent => 2
      xml.instruct!
      xml.ucsxml :version=>"1.1", :xmlns=>"http://ucs.tfcci.com" do |ucsxml|
        ucsxml.request :method => "create" do |request|
          request.cli_id client_id
          request.usr_id user_id
          request.activation :start => Time.now.strftime("%Y%m%d%H%M%S"), :stop => (Time.now + retry_duration).strftime("%Y%m%d%H%M%S") do |activation|
            activation.campaign do |campaign|
              
              request.program :name => "OpenPhin Alert ##{@alert.id}", :desc => @alert.title, :channel => "outdial", :template => "0" do |program|
                program.addresses :address => "c0", :retry_num => "0", :retry_wait => "0"
                program.content do |content|
                  msg = @alert.message
                  content.slot msg, :id => "1", :type => "TTS" 
                end
              end

              campaign.audience do |audience|
                audience.contact do |contact|
                  contact.c0 @device.phone, :type => "phone" 
                end
              end

            end
          end
        end
      end
      
      perform_delivery body
    end

    def perform_delivery(body)
      Dialer.new(url, username, password).deliver(body)
    end

  end
  
end
