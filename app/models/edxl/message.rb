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
    element :datetime_sent, String, :tag => "dateTimeSent"
    element :distribution_status, String, :tag => "distributionStatus"
    element :distribution_type, String, :tag => "distributionType"
    element :combined_confidentiality, String, :tag => "combinedConfidentiality"
  end

  class Message
    include HappyMapper

    tag "EDXLDistribution"
    namespace "urn:oasis:names:tc:emergency:EDXL:DE:1.0"
    element :distribution_id, String, :tag => "distributionID"
    element :sender_id, String, :tag => "senderID"
    element :datetime_sent, String, :tag => "dateTimeSent"
    element :distribution_status, String, :tag => "distributionStatus"
    element :distribution_type, String, :tag => "distributionType"
    element :distribution_reference, String, :tag => "distributionReference"
    element :combined_confidentiality, String, :tag => "combinedConfidentiality"
    has_many :alerts, EDXL::Alert
    has_many :roles, String, :deep => true, :tag => 'recipientRole/value'
    has_many :users, String, :deep => true, :tag => 'explicitAddressValue'
    
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

    class Keyword
      include HappyMapper
      namespace "urn:oasis:names:tc:emergency:EDXL:DE:1.0"
      element :key, String, :tag => 'valueListUrn'
      element :value, String
    end

    has_many :keywords, Keyword

    def fips_codes
      target_areas.map(&:locCodeUN).flatten
    end
    
    def roles
      recipient_roles.map(&:role).flatten
    end


    def delivery_time
      parameter = keywords.detect {|p| p.key =~ /urn:phin:deliverytime/i }
      parameter.value if parameter
    end

    def self.parse(xml, options = {})
      returning super do |message|
        message.alerts.each do |alert|
          next if options[:no_delivery]
          a = ::HanAlert.new(
            :identifier => alert.identifier,
            :message_type => message.distribution_type,
            :alert_references => alert.references,
            :severity => alert.severity,
            :status => alert.status,
            :delivery_time => !alert.delivery_time.blank? ? alert.delivery_time : message.delivery_time,
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
            :jurisdiction_level => alert.jurisdiction_level,
            :acknowledge => alert.acknowledge,
            :certainty => alert.certainty,
            :program => alert.program,
            :sensitive => (message.combined_confidentiality.strip == "Not Sensitive" || message.combined_confidentiality.strip == "NotSensitive") ? "false" : "true",
            :distribution_reference => message.distribution_reference,
            :sender_id => message.sender_id,
            :reference => alert.references,
            :ack_distribution_reference => "#{message.distribution_id},#{message.sender_id},#{Time.parse(message.datetime_sent).utc.iso8601(3)}"
          )
          
          audience = a.audiences.build
          
          message.fips_codes.each do |code|
            j = Jurisdiction.find_by_fips_code(code)
            audience.jurisdictions << j if j
          end
          message.roles.each do |role|
            role = Role.find_by_name(role.strip)
            audience.roles << role if role
          end
          message.users.each do |email|
            user=User.find_by_email(email)
            audience.users << user if user
          end
          
          a.jurisdictions_per_level
          a.save!

          original_alert = ::HanAlert.find_by_identifier(a.alert_references.split(',')[1].strip) if !a.alert_references.blank?
          
          if a.message_type == "Cancel" || a.message_type == "Update"
            a.title = "[#{a.message_type}] - #{a.title}"
            a.original_alert_id = original_alert.id
            a.save!
          end

          a.alert_device_types << AlertDeviceType.create!(:device => 'Device::EmailDevice')
          a.batch_deliver
          Dir.ensure_exists(File.join(Agency[:phin_ms_path]))

          File.open(File.join(Agency[:phin_ms_path], "#{a.identifier}-ACK.edxl"), 'w' ) do |f|
            f.write(a.to_ack_edxl)
          end
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
      @alert ||= ::HanAlert.find_by_identifier(distribution_id.split(',')[0].strip)
    end
    
    def organization
      @organization ||= ::Organization.find_by_phin_oid(distribution_id.split(',')[1].strip)
    end
    
    def acknowledge
      # FIXME: Fragile and broken. :(
      # if !alert.nil?
      #   d = Jurisdiction.federal.first.alert_attempts.find_by_alert_id(alert.id).deliveries.first
      #   d.sys_acknowledged_at = Time.zone.now
      #   d.save!
      # end
    end

    def self.parse(xml, options = {})
      returning super do |message|
        message.acknowledge unless options[:no_delivery]
      end
    end
  end
end
