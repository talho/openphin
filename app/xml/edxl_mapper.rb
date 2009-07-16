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
    class CapParameter
      include HappyMapper
      #namespace :ns1
      element :name, String, :tag => "valueName"
      element :value, String
    end
    class CapInfo
      include HappyMapper
      #namespace "ns1"
      tag "info"
      element :category, String
      element :event, String
      element :urgency, String
      element :severity, String
      element :certainty, String
      element :sender_name, String, :tag => "senderName"
      element :headline, String
      element :description, String
      element :instruction, String
      element :contact, String
      has_many :parameters, CapParameter
    end
    class CapAlert
      include HappyMapper
      namespace "ns1"
      tag "alert"   
      element :identifier, String, :namespace => "ns1"
      element :sender, String, :namespace => "ns1"
      element :sent, DateTime, :namespace => "ns1"
      element :status, String, :namespace => "ns1"
      element :message_type, String, :tag => "msgType", :namespace => "ns1"
      element :references, String, :namespace => "ns1"
      element :scope, String, :namespace => "ns1"
      #element :info, CapInfo
    end
    class EmbeddedXmlContent
      include HappyMapper
      tag "embeddedXMLContent"
      has_one :alert, CapAlert, :namespace => "ns1"
    end
    class XmlContent
      include HappyMapper
      tag "xmlContent"
      has_one :embedded_content, EmbeddedXmlContent
    end
    class ContentObject
      include HappyMapper
      tag "contentObject"
      has_one :xml_content, XmlContent
      element :confidentiality, String
    end
    class TargetArea
      include HappyMapper

      tag "targetArea"
      element "country", String
      has_many "location_code", String, :tag => "locCodeUN"
    end
    class RecipientRole
      include HappyMapper


      tag "recipientRole"
      element :value_list_urn, String, :tag => "valueListURN"
      has_many :values, String
    end
    class ExplicitAddress
      include HappyMapper


      tag "explicitAddress"
      element :explicit_address_scheme, String, :tag => "explicitAddressScheme"
      has_many :explicit_address_value, String, :tag => "explicitAddressValue"
    end
    class EDXLMessage
      include HappyMapper

      tag "EDXLDistribution"
      element :distribution_id, String, :tag => "distributionID"
      element :sender_id, String, :tag => "senderID"
      element :datetime_sent, DateTime, :tag => "dateTimeSent"
      element :distribution_status, String, :tag => "distributionStatus"
      element :distribution_type, String, :tag => "distributionType"
      element :distribution_reference, String, :tag => "distributionReference"
      element :combined_confidentiality, String, :tag => "combinedConfidentiality"
      has_one :recipient_role, RecipientRole
      has_one :explicit_address, ExplicitAddress
      has_many :target_areas, TargetArea
      has_one :content_object, ContentObject, :tag => "contentObject"
    end


