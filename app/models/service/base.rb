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
    
    attr_accessor_with_default(:options){ Hash.new }

    
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
    @@configuration||={}
    @@configuration[self.name] ||= Configuration.new
  end
  
  def self.load_configuration_file(file)
    configuration.options = configuration.options.merge! YAML.load(IO.read(file))[RAILS_ENV]
    if configuration.fake_delivery?
      def self.deliveries 
        @deliveries ||= []
      end
    end
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