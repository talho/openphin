class Service::Swn::Email::Invitation < Service::Swn::Email::Base
  property :invitation
  property :users
  property :username
  property :password
  property :retry_duration

  validates_presence_of :invitation, :username, :password, :retry_duration, :users

  def self.format_activation_time(time)
    time.strftime("%Y%m%d%H%M%S")
  end

  def retry_duration=(duration)
    @retry_duration = duration.to_s.scan(/\d+/).first.to_i.hours
  end

  def build!
    raise "Invalid #{self}, Errors: #{self.errors.full_messages.inspect}" unless valid?

    body = ""
    xml = Builder::XmlMarkup.new :target => body, :indent => 2
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

    body

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
          xml.swn(:id, invitation.id)
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
      xml.swn(:introName, invitation.author.display_name)
    end
  end

  def add_notification(xml)
    xml.swn(:notification) do
      xml.swn(:subject, invitation.subject)
      xml.swn(:body, invitation.body)
    end
  end

  def add_recipients(xml)
    xml.swn(:rcpts) do
      users.each do |user|
        xml.swn(:rcpt) do
          xml.swn(:id, user.id)
          xml.swn(:firstName, user.name)
          xml.swn(:lastName, "")
          xml.swn(:contactPnts) do
            xml.swn(:contactPntInfo, :type => "Email") do
              xml.swn(:id, user.id)
              xml.swn(:label, "Email Device")
              xml.swn(:address, user.email)
            end
          end
        end
      end
    end
  end

end