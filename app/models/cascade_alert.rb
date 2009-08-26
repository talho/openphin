class CascadeAlert
  attr_accessor :alert
  
  def initialize(alert)
    self.alert = alert
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

  
  def sender_id(include_agency_domain=false)
    if include_agency_domain
      "#{Agency[:agency_identifier]}@#{Agency[:agency_domain]}"
    else
      "#{Agency[:agency_identifier]}"
    end

  end

  def distribution_id
    alert.distribution_id
  end
  
  def distribution_reference
    "#{alert.parent.distribution_id},#{sender_id},#{alert.parent.sent_at}" unless alert.parent.nil?
  end
  
  def confidentiality
    alert.sensitive? ? 'Sensitive' : 'NotSensitive'
  end
    
  def to_edxl
    xml = Builder::XmlMarkup.new(:indent => 2)
    xml.instruct!
    xml.EDXLDistribution do
      xml.distributionID alert.distribution_id
      xml.senderID sender_id(true)
      xml.dateTimeSent alert.sent_at
      xml.distributionStatus alert.status
      xml.distributionType alert.message_type
      xml.combinedConfidentiality confidentiality
      xml.recipientRole do
        xml.valueListUrn 'urn:phin:role'
        alert.roles.each do |role|
          xml.value role.name
        end
      end
      xml.distributionReference distribution_reference unless alert.message_type == 'Alert'
      # xml.targetArea do
      #   xml.country 'US'
      #   alert.jurisdictions.each do
      #     xml.locCodeUN jurisdiction.fips_code
      #   end
      # end
      xml.contentObject do
        xml.confidentiality confidentiality
        xml.xmlContent do
          xml.embeddedXMLContent do
            xml.ns1(:alert, "xmlns:ns1".to_sym => 'urn:oasis:names:tc:emergency:cap:1.1') do |cap|
              xml.ns1 :identifier, alert.distribution_id
              xml.ns1 :sender, sender_id
              xml.ns1 :sent, alert.sent_at
              xml.ns1 :status, alert.status
              xml.ns1 :msgType, alert.message_type
              xml.ns1 :references, distribution_reference unless alert.message_type == 'Alert'
              xml.ns1 :explicitAddress do
                xml.ns1 :explicitAddressScheme, "e-mail"
                alert.foreign_users.each do |user|
                  xml.ns1 :explicitAddressValue, user.email
                end
              end if alert.foreign_users.any?
              xml.ns1 :targetArea do
                alert.jurisdictions.foreign.each do |j|
                  xml.ns1 :locCodeUN, j.fips_code
                end
              end if alert.jurisdictions.foreign.any?
              xml.ns1 :scope, 'Restricted'
              xml.ns1 :info do |info|
                xml.ns1 :category, 'Health'
                xml.ns1 :event, 'HAN'
                xml.ns1 :urgency, 'Unknown'
                xml.ns1 :severity, alert.severity
                xml.ns1 :certainty, 'Very Likely'
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
                  xml.ns1 :valueName, 'JurisdictionalLevel'
                  xml.ns1 :value, alert.jurisdictional_level
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