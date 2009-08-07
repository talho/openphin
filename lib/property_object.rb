module PropertyObject
  module InstanceMethods
    def initialize(attrs={})
      super()
      attrs = attrs.symbolize_keys
      (self.class.properties.keys & attrs.keys).each do |key|
        self.send("#{key}=", attrs[key])
      end
      unknown_properties = (attrs.keys - self.class.properties.keys)
      if unknown_properties.any?
        raise "Unknown properties: #{unknown_properties.join(',')}"
      end
    end
  end
  
  module ClassMethods
    def properties
      @properties ||= {}
    end
  
    def property(field)
      properties[field.to_sym] = true
      attr_accessor field
    end
  end
end