=begin
    OpenPHIN is an opensource implementation of the CDC guidelines for 
    a public health information network.
    
    Copyright (C) 2009  Texas Association of Local Health Officials

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU Affero General Public License as
    published by the Free Software Foundation, either version 3 of the
    License, or (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU Affero General Public License for more details.

    You should have received a copy of the GNU Affero General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.

=end

module EDXL
  class MessageContainer
    include HappyMapper

    tag "EDXLDistribution"
    namespace "urn:oasis:names:tc:emergency:EDXL:DE:1.0"
    element :distribution_id, String, :tag => "distributionID"
    element :sender_id, String, :tag => "senderID"
    element :datetime_sent, DateTime, :tag => "dateTimeSent"
    element :distribution_status, String, :tag => "distributionStatus"
    element :distribution_type, String, :tag => "distributionType"
    element :distribution_reference, String, :tag => "distributionReference"
    element :combined_confidentiality, String, :tag => "combinedConfidentiality"
  end

  class Message
    include HappyMapper

    tag "EDXLDistribution"
    namespace "urn:oasis:names:tc:emergency:EDXL:DE:1.0"
    element :distribution_id, String, :tag => "distributionID"
    element :sender_id, String, :tag => "senderID"
    element :datetime_sent, DateTime, :tag => "dateTimeSent"
    element :distribution_status, String, :tag => "distributionStatus"
    element :distribution_type, String, :tag => "distributionType"
    element :distribution_reference, String, :tag => "distributionReference"
    element :combined_confidentiality, String, :tag => "combinedConfidentiality"
    has_many :alerts, EDXL::Alert
    has_many :roles, String, :deep => true, :tag => 'recipientRole/value'
    has_many :users, String, :tag => 'explicitAddress/explicitAddressValue'
    
    class TargetArea
      include HappyMapper
      namespace "urn:oasis:names:tc:emergency:EDXL:DE:1.0"
      tag "targetArea"
      has_many :country, String, :tag => "country"
      has_many :locCodeUN, String, :tag => "locCodeUN"
    end

    has_many :target_areas, TargetArea

    class RecipientRole
      include HappyMapper
      namespace "urn:oasis:names:tc:emergency:EDXL:DE:1.0"
      tag "recipientRole"
      has_many :valueListUrn, String, :tag => "valueListUrn"
      has_many :role, String, :tag => "value"
    end
    
    has_many :recipient_roles, RecipientRole
    
    def fips_codes
      target_areas.map(&:locCodeUN).flatten
    end
    
    def roles
      recipient_roles.map(&:role).flatten
    end

    def self.parse(xml, options = {})
      returning super do |message|
        message.alerts.each do |alert|
          a = ::Alert.create!(
            :identifier => alert.identifier,
            :message_type => message.distribution_type,
            :references => alert.references,
            :severity => alert.severity,
            :status => alert.status,
            :delivery_time => alert.delivery_time,
            :message => alert.description,
            :category => alert.category,
            :from_organization => Organization.find_by_phin_oid(alert.sender),
            :from_organization_oid => alert.sender,
            :from_organization_name => alert.from_organization_name,
            :title => alert.title,
            :urgency => alert.urgency,
            :scope => alert.scope,
            :program_type => alert.program_type,
            :sent_at => alert.sent_at,
            :jurisdictional_level => alert.jurisdictional_level,
            :acknowledge => alert.acknowledge,
            :certainty => alert.certainty,
            :program => alert.program,
            :sensitive => message.combined_confidentiality == "NotSensitive" ? "false" : "true"
          )

          message.fips_codes.each do |code|
            j = Jurisdiction.find_by_fips_code(code)
            a.jurisdictions << j if j
          end
          message.roles.each do |role|
            role = Role.find_by_name(role.strip)
            a.roles << role if role
          end
          message.users.each do |email|
            user=User.find_by_email(email)
            a.users << user if user
          end
          a.alert_device_types << AlertDeviceType.create!(:device => 'Device::EmailDevice')
          a.batch_deliver
        end
      end
    end
  end
  
  class AckMessage
    include HappyMapper

    tag "EDXLDistribution"
    namespace = "urn:oasis:names:tc:emergency:EDXL:DE:1.0"
    element :distribution_id, String, :tag => "distributionID"
    element :sender_id, String, :tag => "senderID"
    element :datetime_sent, DateTime, :tag => "dateTimeSent"
    element :distribution_status, String, :tag => "distributionStatus"
    element :distribution_type, String, :tag => "distributionType"
    element :distribution_reference, String, :tag => "distributionReference"
    element :combined_confidentiality, String, :tag => "combinedConfidentiality"

    def alert
      @alert ||= ::Alert.find_by_identifier(distribution_id.split(',')[0].strip)
    end
    
    def organization
      @organization ||= ::Organization.find_by_phin_oid(distribution_id.split(',')[1].strip)
    end
    
    def acknowledge
      if !alert.nil?
        if alert.organizations.empty?
          d = alert.jurisdictions.federal.first.deliveries.first
          d.sys_acknowledged_at = Time.zone.now
        else
          d = alert.alert_attempts.first.deliveries.first
          d.sys_acknowledged_at = Time.zone.now
        end
        d.save!
      end
    end

    def self.parse(xml, options = {})
      returning super do |message|
        message.acknowledge
      end
    end
  end
end


# class CapParameter
#   include HappyMapper
#   namespace "http://schemas.google.com/analytics/2009"
#   element :name, String, :tag => "valueName"
#   element :value, String
# end
# class CapInfo
#   include HappyMapper
#   namespace "http://schemas.google.com/analytics/2009"
#   tag "info"
#   element :category, String
#   element :event, String
#   element :urgency, String
#   element :severity, String
#   element :certainty, String
#   element :sender_name, String, :tag => "senderName"
#   element :headline, String
#   element :description, String
#   element :instruction, String
#   element :contact, String
#   has_many :parameters, CapParameter
# end
# class EmbeddedXmlContent
#   include HappyMapper
#   tag "embeddedXMLContent"
#   has_one :alert, CapAlert
# end
# class XmlContent
#   include HappyMapper
#   tag "xmlContent"
#   has_one :embedded_content, EmbeddedXmlContent
# end
# class ContentObject
#   include HappyMapper
#   tag "contentObject"
#   has_one :xml_content, XmlContent
#   element :confidentiality, String
# end
# class TargetArea
#   include HappyMapper
# 
#   tag "targetArea"
#   element "country", String
#   has_many "location_code", String, :tag => "locCodeUN"
# end
# class RecipientRole
#   include HappyMapper
# 
# 
#   tag "recipientRole"
#   element :value_list_urn, String, :tag => "valueListURN"
#   has_many :values, String
# end
# class ExplicitAddress
#   include HappyMapper
# 
# 
#   tag "explicitAddress"
#   element :explicit_address_scheme, String, :tag => "explicitAddressScheme"
#   has_many :explicit_address_value, String, :tag => "explicitAddressValue"
# end
# 
# 
