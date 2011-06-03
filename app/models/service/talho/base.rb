class Service::TALHO::Base
  extend PropertyObject::ClassMethods
  include PropertyObject::InstanceMethods

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
    
  def self.configuration
    #configuration on a per-class basis
    @configuration||={}
    @configuration[self.name] ||= Configuration.new
  end

  def self.load_configuration_file(file)
    configuration.options = configuration.options.merge! YAML.load(IO.read(file))[RAILS_ENV]
    if configuration.fake_delivery?
      def self.deliveries
        @deliveries ||= []
      end

      def self.clearDeliveries
        @deliveries = []
      end
    end
  end
  private

  def perform_delivery(body)
    
  end

end