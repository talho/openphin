class Service::Base

  # Configuration is used to configure services. It should
  # be configured through a block. For example:
  #   Service::Sms.configure do |config|
  #     config.delivery_method = :deliver
  #   end
  #
  # You can also configure arbitrary options that a service supports
  # by storing them in the options hash. For example:
  #   Service::Sms.configure do |config|
  #     config.options[:sms_config] = YAML.load("sms_config.yml")
  #   end
  #
  # The two possible delivery options are :test and :deliver. The
  # :test delivery method should be used in the 'test' and 'cucumber'
  # environments. It will add a #deliveries method to the service
  # in which you can verify that messages are being delivered.
  # For example:
  #   Service::Sms.configure do |config|
  #     config.delivery_method = :test
  #   end
  #   
  #   # in test after a delivery is performed
  #   Service::Sms.deliveries # => array of delivered messages
  # 
  # The default delivery method is +deliver+
  class Configuration
    FAKE_DELIVERY_METHOD = :test
    DEFAULT_DELIVERY_METHOD = :deliver
    
    attr_accessor_with_default :options, {}
    
    def delivery_method=(what)
      @delivery_method = what
    end
    
    def delivery_method
      @delivery_method ||= DEFAULT_DELIVERY_METHOD
    end
    
    def fake_delivery?
      @delivery_method == :test
    end
  end
  
  # =================
  # = CLASS METHODS =
  # =================
  
  def self.configure(&blk)
    yield configuration
    if configuration.fake_delivery?
      def self.deliveries 
        @deliveries ||= []
      end
    end
  end
  
  def self.configuration
    @configuration ||= Configuration.new
  end
  
  # =================
  # = INSTANCE METHODS =
  # =================
  
  # Renders a template found in app/views/services/<name of service>/<template>
  # with the passed in hash of local variables.
  def render(template, locals={})
    view = ActionView::Base.new ApplicationController.view_paths
    view.extend FormatHelper
    view.extend SmsHelper
    view.render :file => "services/#{self.class.name.demodulize.tableize}/#{template}", :locals => locals
  end
  
end