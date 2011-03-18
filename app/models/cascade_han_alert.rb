class CascadeHanAlert
  attr_accessor :alert
  
  def initialize(alert)
    alert.reload
    self.alert = alert
  end
  
  def audience
    alert.audiences.detect{|a| !a.is_a?(Group) }
  end
  
  def yes_no(boolean)
    boolean ? 'Yes' : 'No'
  end
  
  def author
    [:name, :title, :email, :phone].map{|method| alert.author.send(method) }.reject(&:blank?).join("\n")
  end
  
  def agency_name
    Agency[:agency_name]
  end

  def distribution_id
    alert.distribution_id
  end
  
  def confidentiality
    alert.sensitive? ? 'Sensitive' : 'NotSensitive'
  end
    
  def to_edxl
    xml = Builder::XmlMarkup.new(:indent => 2)
    xml.instruct!
    xml.EDXLDistribution(:xmlns => 'urn:oasis:names:tc:emergency:EDXL:DE:1.0') do
      xml.distributionID alert.distribution_id
      xml.senderID alert.sender_id
      xml.dateTimeSent alert.sent_at.utc.iso8601(3)
      xml.distributionStatus alert.status
      xml.distributionType alert.message_type
      xml.combinedConfidentiality confidentiality
      xml.recipientRole do
        xml.valueListUrn 'urn:phin:role'
        xml.value "Health Alert and Communications Coordinator" if audience.roles.size > 0
        audience.roles.each do |role|
          xml.value role.name unless role.name == "Health Alert and Communications Coordinator"
        end
      end unless audience.roles.size == 0
      xml.distributionReference alert.distribution_reference unless alert.message_type == 'Alert'
      xml.explicitAddress do
        xml.explicitAddressScheme "e-mail"
        audience.foreign_users.each do |user|
          xml.explicitAddressValue user.email
        end
      end if audience.foreign_users.any?
      xml.targetArea do
        audience.jurisdictions.foreign.each do |j|
          xml.locCodeUN j.fips_code
        end
      end if audience.jurisdictions.foreign.any? && !audience.jurisdictions.foreign.map(&:fips_code).compact.empty?
      # xml.targetArea do
      #   xml.country 'US'
      #   audience.jurisdictions.each do
      #     xml.locCodeUN jurisdiction.fips_code
      #   end
      # end
      xml.contentObject do
        xml.confidentiality confidentiality
        xml.xmlContent do
          xml.embeddedXMLContent do
            xml.ns1(:alert, "xmlns:ns1".to_sym => 'urn:oasis:names:tc:emergency:cap:1.1') do |cap|
              xml.ns1 :identifier, alert.distribution_id
              xml.ns1 :sender, alert.sender_id.split('@')[0]
              xml.ns1 :sent, alert.sent_at.utc.iso8601(3)
              xml.ns1 :status, alert.status
              xml.ns1 :msgType, alert.message_type
              xml.ns1 :references, alert.alert_references unless alert.message_type == 'Alert'
              xml.ns1 :scope, 'Restricted'
              xml.ns1 :info do |info|
                xml.ns1 :category, 'Health'
                xml.ns1 :event, 'HAN'
                xml.ns1 :urgency, 'Unknown'
                xml.ns1 :severity, alert.severity
                xml.ns1 :certainty, 'Likely'
                xml.ns1 :senderName, agency_name
                xml.ns1 :headline, alert.title
                xml.ns1 :description, alert.message
                xml.ns1 :contact, author
                
                xml.ns1 :parameter do
                  xml.ns1 :valueName, 'Acknowledge'
                  xml.ns1 :value, yes_no(alert.acknowledge?)
                end
                
                xml.ns1 :parameter do
                  xml.ns1 :valueName, 'DeliveryTime'
                  xml.ns1 :value, alert.delivery_time
                end
                
                xml.ns1 :parameter do
                  xml.ns1 :valueName, 'Level'
                  xml.ns1 :value, alert.jurisdiction_level
                end
                
                xml.ns1 :parameter do
                  xml.ns1 :valueName, 'ProgramType'
                  xml.ns1 :value, 'Alert'  #alert.program_type
                end
               
              end
            end
          end
        end
      end
      
    end
  end
  
end