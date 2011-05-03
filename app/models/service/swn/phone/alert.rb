class Service::SWN::Phone::Alert < Service::SWN::Phone::Base
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
    unless alert.message_recording_file_name.blank?
    body = <<EOF
--MIME_boundary
Content-Type: text/xml; charset=UTF-8
Content-Transfer-Encoding: 8bit
Content-ID: <#{alert.alert_identifier}@#{Agency[:agency_domain]}>

#{body}
--MIME_boundary
Content-Type: audio/x-avi
Content-Transfer-Encoding: binary
Content-Location: "#{alert.message_recording_file_name}"

#{Base64.encode64(IO.read(alert.message_recording.path))}
--MIME_boundary--

EOF
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
          xml.swn(:id, alert.alert_identifier + "-PHONE")
          xml.swn(:custSentTimestamp, Time.now.utc.iso8601(3))
          add_sender xml
          add_notification xml
          add_call_down xml
          
          add_recipients xml
	        #TODO: uncomment if and when SWN introduces ability to attach voice files.
#          add_program_content_with_audio xml unless alert.message_recording_file_name.blank?
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
      xml.swn(:body, construct_message)
    end
  end

  def add_call_down(xml)
    if alert.acknowledge? && alert.original_alert.nil?
      sorted_messages = alert.call_down_messages.sort {|a, b| a[0]<=>b[0]}
      sorted_messages.each do |key, call_down|
        xml.swn(:gwbText, call_down)
      end
    end

  end

  def add_recipients(xml)
    xml.swn(:rcpts) do
      users.each do |user|
        xml.swn(:rcpt) do
          xml.swn(:id, user.id)
          xml.swn(:firstName, user.first_name)
          xml.swn(:lastName, user.last_name)
          xml.swn(:contactPnts) do
            user.devices.phone.each do |phone_device|
              xml.swn(:contactPntInfo, :type => "Voice") do
                xml.swn(:id, phone_device.id)
                xml.swn(:label, "Phone Device")
                xml.swn(:address, phone_device.phone)
              end
            end
          end
        end
      end
    end
  end

#  def add_program_content_with_audio(xml)
#      xml.swn(:soundName, alert.message_recording_file_name )
#  end

  def construct_message
    output = "The following is an alert from the Texas Public Health Information Network.  "
    if output.size + alert.message.size > 1000
      footer = ".  The rest of this message is unavailable.  Please visit the T X Fin website for the rest of this alert."
      output += alert.message[0..(1000 - output.size - footer.size)] + footer
    else
      output += alert.message
    end
    output
  end
end