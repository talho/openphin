class Service::Phone < Service::Base
  load_configuration_file RAILS_ROOT+"/config/phone.yml"
  
  def self.deliver_alert(alert, user, device, config=Service::Phone.configuration)
    initialize_fake_delivery(config) if config.fake_delivery?
    TFCC.new(alert, user, device, config).deliver
  end

  class << self
    private
    
    # Overwrites TFCC.deliver to push message onto 
    # Service::Phone.deliveries.
    def initialize_fake_delivery(config) # :nodoc:
      TFCC.instance_eval do
        define_method(:perform_delivery) do |body|
          Service::Phone.deliveries << OpenStruct.new(:body => body)
          config.options[:default_response] ||= "200 OK"
        end
      end
    end
  end
  
  class TFCC
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
          :headers => { 'Content-Type' => 'text/xml', 'Accept' => 'text/xml/html'})
        PHONE_LOGGER.info "21CC Response:\n#{response}\n\n"
      end
    end
    
    def initialize(alert, user, device, config)
      @alert, @user, @device, @config = alert, user, device, config
    end
    
    def deliver
      PHONE_LOGGER.info <<-EOT.gsub(/^\s+/, '')
        |Building alert message:
        |  alert: #{@alert.id}
        |  user_id: #{@user.id}
      EOT
      
      body = AlertWithoutAcknowledgmentBuilder.build(
        @config.to_hash.merge(:alert => @alert, :user => @user, :device => @device).symbolize_keys
      )
      perform_delivery body
    end
    
    private
    
    def perform_delivery(body)
      Dialer.new(url, username, password).deliver(body)
    end

  end
  
end
