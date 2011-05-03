class Service::SWN::Fax::Alert < Service::SWN::Fax::Base
  property :alert
  property :users
  property :username
  property :password
  property :retry_duration

  validates_presence_of :alert, :username, :password, :retry_duration, :users
     
  
  def self.format_activation_time(time)
    time.strftime("%Y%m%d%H%M%S")
  end
  
  def retry_duration=(duration)
    @retry_duration = duration.to_s.scan(/\d+/).first.to_i.hours
  end
  
  def build!(start_time=Time.now)
    raise "Invalid #{self}, Errors: #{self.errors.full_messages.inspect}" unless valid?

    body = ""
    xml = Builder::XmlMarkup.new :target => body, :indent => 2
#    xml.instruct!
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
          xml.swn(:id, alert.alert_identifier)
          xml.swn(:custSentTimestamp, Time.now.utc.iso8601(3))
          add_sender xml
          add_notification xml
          add_recipients xml
        end
      end
    end
  end
  

  def add_sender(xml)
    xml.swn(:sender) do
      xml.swn(:introName, alert.author.display_name) unless alert.author.nil?
      xml.swn(:introOrganization, alert.from_organization) unless alert.from_organization.blank?
      xml.swn(:introOrganization, alert.from_jurisdiction) unless alert.from_jurisdiction.blank?
      xml.swn(:phone, alert.caller_id) unless alert.caller_id.blank?
    end
  end

  def add_notification(xml)
    xml.swn(:notification) do
      xml.swn(:subject, alert.title)
      xml.swn(:body, alert.short_message)
    end
  end

  def add_recipients(xml)
    xml.swn(:rcpts) do
      users.each do |user|
        user.devices.fax.each do |fax_device|
          xml.swn(:rcpt) do
            xml.swn(:id, user.id)
            xml.swn(:firstName, user.first_name)
            xml.swn(:lastName, user.last_name)
            xml.swn(:contactPnts) do
              xml.swn(:contactPntInfo, :type => "Text") do
                xml.swn(:id, user.id)
                xml.swn(:label, "FAX Device")
                xml.swn(:address, "#{fax_device.fax}@fax.sendwordnow.com")
              end
            end
          end
        end
      end
    end
  end

end