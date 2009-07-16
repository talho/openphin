require 'happymapper'

module EDXL
  class Alert
    include HappyMapper
    namespace "http://schemas.google.com/analytics/2009"
    tag "alert"
    element :identifier, String
    element :sender, String
    element :sent, DateTime
    element :status, String
    element :message_type, String, :tag => "msgType"
    element :references, String
    element :scope, String
    element :severity, String, :deep => true
    #element :info, CapInfo
    
    class Parameter
      include HappyMapper
      namespace "http://schemas.google.com/analytics/2009"
      element :key, String, :tag => 'valueName'
      element :value, String
    end
    
    has_many :parameters, Parameter
    
    def delivery_time
      parameter = parameters.detect {|p| p.key == 'DeliveryTime' }
      parameter.value if parameter
    end
  end
end