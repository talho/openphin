# == Schema Information
#
# Table name: alerts
#
#  id                     :integer         not null, primary key
#  title                  :string(255)
#  message                :text
#  severity               :string(255)
#  status                 :string(255)
#  acknowledge            :boolean
#  author_id              :integer
#  created_at             :datetime
#  updated_at             :datetime
#  sensitive              :boolean
#  delivery_time          :integer
#  sent_at                :datetime
#  message_type           :string(255)
#  program_type           :string(255)
#  from_organization_id   :integer
#  from_organization_name :string(255)
#  from_organization_oid  :string(255)
#  identifier             :string(255)
#  scope                  :string(255)
#  category               :string(255)
#  program                :string(255)
#  urgency                :string(255)
#  certainty              :string(255)
#  jurisdictional_level   :string(255)
#  references             :string(255)
#  from_jurisdiction_id   :integer
#  original_alert_id      :integer
#

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
    element :description, String, :deep => true
    element :category, String, :deep => true
    element :from_organization_name, String, :deep => true, :tag => "senderName"
    element :title, String, :deep => true, :tag => "headline"
    element :urgency, String, :deep => true
    element :scope, String, :deep => true
    element :message_type, String, :tag => "msgType"
    element :sent_at, String, :tag => "sent"
    element :certainty, String, :deep => true
    element :program, String, :deep => true, :tag => "event"
    
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

    def program_type
      parameter = parameters.detect {|p| p.key == 'ProgramType' }
      parameter.value if parameter
    end

    def jurisdictional_level
      parameter = parameters.detect {|p| p.key == 'Level' }
      parameter.value if parameter
    end

    def acknowledge
      parameter = parameters.detect {|p| p.key == 'Acknowledge' }
      !parameter.nil? && parameter.value == "Yes"
    end
  end
end
