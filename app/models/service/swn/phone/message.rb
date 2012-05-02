class Service::Swn::Phone::Message < Service::Swn::Phone::Base
  property :message
  property :username
  property :password
  property :retry_duration

  def self.format_activation_time(time)
    time.strftime("%Y%m%d%H%M%S")
  end

  def retry_duration=(duration)
    @retry_duration = duration.to_s.scan(/\d+/).first.to_i.hours
  end

  def build!
    raise "Invalid #{self}, Errors: #{self.errors.full_messages.inspect}" unless valid?

    body = ""
    xml = ::Builder::XmlMarkup.new :target => body, :indent => 2
    #xml.instruct!
    xsi = "xmlns:xsi".to_sym
    xsd = "xmlns:xsd".to_sym
    soapenv = "xmlns:soap-env".to_sym
    soapenc = "xmlns:soap-enc".to_sym
    xml.tag!("soap-env:Envelope", xsi => "http://www.w3.org/2001/XMLSchema-instance", xsd => "http://www.w3.org/2001/XMLSchema",
      soapenv => "http://schemas.xmlsoap.org/soap/envelope/", soapenc => "http://schemas.xmlsoap.org/soap/encoding/") do
      add_header xml
      xml.tag!("soap-env:Body") do
        add_send_notification xml
      end
    end
  end

  private

  def add_header(xml)
    xml.tag!("soap-env:Header") do
      xml.AuthCredentials :xmlns => "http://www.sendwordnow.com/notification" do
        xml.username username
        xml.password password
      end
    end
  end

  def add_send_notification(xml)
    xmlns = "xmlns:swn".to_sym
    xml.swn(:sendNotification, xmlns => "http://www.sendwordnow.com/notification") do
      xml.swn(:pSendNotificationInfo) do
        xml.swn(:SendNotificationInfo) do
          xml.swn(:id, message.messageId + "-PHONE")
          xml.swn(:custSentTimestamp, Time.now.utc.iso8601(3))
          add_sender xml
          add_notification xml
          add_notification_responses xml
          add_recipients xml
        end
      end
    end
  end

  def add_sender(xml)
    xml.swn(:sender) do
      xml.swn(:introName, message.Author.display_name) unless message.Author.blank?
      if message.Behavior && message.Behavior.Delivery && message.Behavior.Delivery.Providers
        provider = message.Behavior.Delivery.Providers.select{|p| p.name == "swn"}


        introOrganization = message.Behavior.Delivery.customAttributes.select{|c| c.name == "introOrganization"}
        unless introOrganization.blank?
         introOrganization = introOrganization.first
         unless introOrganization.blank?
           xml.swn(:introOrganization, introOrganization.Value) unless introOrganization.Value.blank?
         end
        end

        phone = message.Behavior.Delivery.customAttributes.select{|c| c.name == "phone"}
        unless phone.blank?
          phone = phone.first
          xml.swn(:phone, phone.Value) unless phone.blank? || phone.Value.blank?
        end
      end
    end
  end

  def add_notification(xml)
    xml.swn(:notification) do
      provider = message.Behavior.Delivery.Providers.select{|c| c.name == "swn" && c.device == "Phone"}.first
      title = ""
      messagetext = ""
      if provider.blank? || provider.Messages.blank?
        title = message.Messages.select{|m| m.name == "title"}.first.Value
        messagetext = message.Messages.select{|m| m.name == "message"}.first.Value
      else
        messageref = provider.Messages.select{|m| m.name == "title"}.first.ref
        title = message.Messages.select{|m| m.name == messageref}.first.Value

        messageref = provider.Messages.select{|m| m.name == "message"}.first.ref
        messagetext = message.Messages.select{|m| m.name == messageref}.first.Value
      end

      xml.swn(:subject, title)
      xml.swn(:body, messagetext)
    end
  end

  def add_notification_responses(xml)
    unless message.IVRTree.blank?
      provider = message.Behavior.Delivery.Providers.select{|c| c.name == "swn" && c.device == "Phone"}.first

      message.IVRTree.select{|ivr| ivr.name == provider.ivr}.each do |ivr|
        ivr.ContextNodes.select{|node| node.operation == "TTS"}.each do |node|
          xml.swn(:gwbText, node.response.value)
        end
      end unless provider.blank? || provider.ivr.blank?
    end
  end

  def add_recipients(xml)
    xml.swn(:rcpts) do
      message.Recipients.each do |recipient|
        xml.swn(:rcpt) do
          xml.swn(:id, recipient.id)
          xml.swn(:firstName, recipient.givenName)
          xml.swn(:lastName, recipient.surname)
          xml.swn(:contactPnts) do
            recipient.Devices.select{|d| d.device_type == "Phone"}.each do |device|
              xml.swn(:contactPntInfo, :type => "Voice") do
                xml.swn(:id, device.id)
                xml.swn(:label, "Phone Device")
                xml.swn(:address, device.URN)
              end
            end
          end
        end
      end
    end
  end
end