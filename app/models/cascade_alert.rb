class CascadeAlert
  attr_accessor :alert
  
  def initialize(alert)
    self.alert = alert
  end
  
  def yes_no(boolean)
    boolean ? 'Yes' : 'No'
  end
  
  def author
    [:name, :title, :email, :phone].map{|method| alert.author.send(method) }.join("\n")
  end
  
  def agency_name
    Agency[:agency_name]
  end
  
  def distribution_id
    "#{agency_name}-2009-#{alert.id}"
  end
  
  def sender_id
    "#{Agency[:agency_identifier]}@#{Agency[:agency_domain]}"
  end
  
  def sent_at
    # FIXME: format
    alert.sent_at
  end
  
  def distribution_reference
    "#{distribution_id},#{sender_id},#{sent_at}"
  end
  
  def confidentiality
    alert.sensitive? ? 'Sensitive' : 'NotSensitive'
  end
    
  def to_edxl
    edxl = Builder::XmlMarkup.new
    edxl.instruct!
    edxl.EDXLDistribution do |root|
      root.distributionID distribution_id
      root.senderID sender_id
      root.dateTimeSent sent_at
      root.distributionStatus alert.status
      root.distributionType alert.message_type
      root.combinedConfidentiality confidentiality
      root.recipientRole do |recipientRole|
        recipientRole.valueListUrn 'urn:phin:role'
        alert.roles.each do |role|
          recipientRole.value role.name
        end
      end
      root.distributionReference distribution_reference unless alert.message_type == 'Alert'
      # root.targetArea do |targetArea|
      #   targetArea.country 'US'
      #   alert.jurisdictions.each do |jurisdiction|
      #     targetArea.locCodeUN jurisdiction.fips_code
      #   end
      # end
      root.contentObject do |content|
        content.confidentiality confidentiality
        content.xmlContent do |xmlContent|
          xmlContent.embeddedXMLContent do |embeddedXMLContent|
            embeddedXMLContent.alert(:ns1, "xmlns:ns1".to_sym => 'urn:oasis:names:tc:emergency:cap:1.1') do |cap|
              cap.identifier distribution_id
              cap.sender sender_id
              cap.sent sent_at
              cap.status alert.status
              cap.msgType alert.message_type
              cap.references distribution_reference unless alert.message_type == 'Alert'
              cap.scope 'Restricted'
              cap.info do |info|
                info.category 'Health'
                info.event 'HAN'
                info.urgency 'Unknown'
                info.severity alert.severity
                info.certainty 'Very Likely'
                info.senderName agency_name
                info.headline alert.title
                info.description alert.message
                info.contact author
                
                info.parameter do |p|
                  p.valueName 'Acknowledge'
                  p.value yes_no(alert.acknowledge?)
                end
                
                info.parameter do |p|
                  p.valueName 'DeliveryTime'
                  p.value alert.delivery_time
                end
                
                info.parameter do |p|
                  p.valueName 'JurisdictionalLevel'
                  p.value 'Federal'
                end
                
                info.parameter do |p|
                  p.valueName 'ProgramType'
                  p.value alert.program_type
                end
               
              end
            end
          end
        end
      end
      
    end
  end
  
end