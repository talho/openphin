require 'nokogiri'

class Service::Phone < Service::Base
  load_configuration_file RAILS_ROOT+"/config/phone.yml"

  def self.deliver_alert(alert, user, config=Service::Phone.configuration)
    initialize_fake_delivery(config) if config.fake_delivery?
    response = TFCC.new(alert, config, [user])
    TFCC::CampaignActivationResponse.build(response,alert)
  end

    
  def self.batch_deliver_alert(alert, config=Service::Phone.configuration)
    initialize_fake_delivery(config) if config.fake_delivery?
    users = alert.alert_attempts.with_device(Device::PhoneDevice).map{ |aa| aa.user }
    response = TFCC.new(alert, config, users).batch_deliver
    TFCC::CampaignActivationResponse.build(response,alert)
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
        return response
      end
    end
    
    class CampaignActivationResponse < ActiveRecord::Base
      set_table_name "tfcc_campaign_activation_response"
      belongs_to :alert

      def self.build(response, alert)
        if !alert.blank?
          if !response.blank? && !response['ucsxml'].blank? && !response['ucsxml']['version'].blank?
            act_id = response['ucsxml']['response']['activation']['act_id']
            camp_id = response['ucsxml']['response']['activation']['camp_id']
            txn_id = response['ucsxml']['response']['txn_id']
            txn_msg = response['ucsxml']['response']['txn_msg']
            txn_err = response['ucsxml']['response']['txn_err']
            self.create!(:alert => alert, :activation_id => act_id, :campaign_id => camp_id, :transaction_id => txn_id, :transaction_msg => txn_msg, :transaction_error => txn_err)
          else
            self.create!(:alert => alert)
          end
        end
      end
    end
    
    class DetailedActivationResults
      include HTTParty
      #format :html     # use if you need to see in xml format, otherwise response is an array
      #set_table_name "tfcc_detailed_activation_results"
      
      def self.build(campaign_activation, options, type = "outdial")
        url, username, password, client_id, user_id = options['url'], options['username'], options['password'], options['client_id'], options['user_id']

        body = ""
        xml = Builder::XmlMarkup.new :target => body, :indent => 2
        xml.instruct!
        xml.ucsxml :version=>"1.1", :xmlns=>"http://ucs.tfcci.com" do |ucsxml|
          ucsxml.request :method => "query" do |request|
            request.cli_id client_id
            request.usr_id user_id
            request.activation_detail :start_result => "0", :results_requested => "30000" do |activation_detail|
              activation_detail.id campaign_activation.activation_id
              activation_detail.channel type
            end
          end
        end
        PHONE_LOGGER.info "Sending activation detail request at #{Time.now}"
        response = self.post(url, 
          :body => body, 
          :basic_auth => {:username => username, :password => password},
          :headers => { 'Content-Type' => 'text/xml', 'Accept' => 'text/xml/html'})
        PHONE_LOGGER.info "21CC Response:\n#{response}\n\n"
        return response
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
      
      body = Service::TFCC::Phone::Alert.new(
        :alert => @alert, 
        :users => @users,
        :client_id => @config['client_id'],
        :user_id => @config['user_id'],
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
      
      body = Service::TFCC::Phone::Alert.new(
        :alert => @alert, 
        :users => @users, 
        :client_id => @config['client_id'],
        :user_id => @config['user_id'],
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
