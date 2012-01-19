class Service::Tfcc::Phone::Alert < Service::Tfcc::Phone::Base
  property :alert
  property :users
  property :client_id
  property :user_id
  property :retry_duration
  
  validates_presence_of :alert, :client_id, :user_id, :retry_duration, :users
  
  def self.format_activation_time(time)
    time.strftime("%Y%m%d%H%M%S")
  end
  
  def retry_duration=(duration)
    @retry_duration = duration.to_s.scan(/\d+/).first.to_i.hours
  end
  
  def build!(start_time=Time.now)
    raise "Invalid #{self}, Errors: #{self.errors.full_messages.inspect}" unless valid?

    start_at = self.class.format_activation_time(start_time)
    stop_at =  self.class.format_activation_time(start_time + retry_duration)
    caller_id = alert.caller_id.nil? || alert.caller_id.blank? ? "" : alert.caller_id

    body = ""
    xml = Builder::XmlMarkup.new :target => body, :indent => 2
    xml.instruct!
    xml.ucsxml :version=>"1.1", :xmlns=>"http://ucs.tfcci.com" do
      xml.request :method => "create" do
        xml.cli_id client_id
        xml.usr_id user_id
        xml.activation :start => start_at, :stop => stop_at, :caller_id => caller_id do
          xml.campaign do
            add_program  xml
            add_audience xml
          end
        end
      end
    end
  end
  
  private

  def add_program(xml)
    xml.program :name => "TXPhin Alert ##{alert.id}", :desc => alert.title, :channel => "outdial", :template => "#{alert.acknowledge? ? 9 : 0}" do
      xml.addresses :address => "c1", :retry_num => "0", :retry_wait => "0"
      xml.content do
        if alert.message_recording_file_name.blank?
          add_program_content_without_audio xml
        else
          add_program_content_with_audio xml
        end
      end
    end
  end
  
  def add_program_content_without_audio(xml)
    xml.slot alert.short_message, :id => "1", :type => "TTS"
    add_acknowledgement xml if alert.acknowledge?
  end
  
  def add_program_content_with_audio(xml)
    xml.slot Base64.encode64(IO.read(alert.message_recording.path)), :id => "1", :type => "VOICE", :encoding => "base64", :format => "wav"
    add_acknowledgement xml if alert.acknowledge?
  end
  
  def add_acknowledgement(xml)
    msg = "You have received a Health Alert.  Please login to the Health Alert Network Application to view the alert message."
    xml.slot msg, :id => "2", :type => "TTS"
    msg = "Please press one to acknowledge this health alert."
    xml.slot msg, :id => "3", :type => "TTS"
    msg = "The number pressed is not valid.  Please press one to acknowledge this health alert."
    xml.slot msg, :id => "4", :type => "TTS"
    msg = "You have failed to acknowledge this message.  Good-bye."
    xml.slot msg, :id => "5", :type => "TTS"
    msg = "You have successfully acknowledged this health alert.  Thanks for your cooperation.  Good-bye."
    xml.slot msg, :id => "6", :type => "TTS"
  end

  def add_audience(xml)
    xml.audience do 
      users.each do |user|
        user.devices.phone.each do |phone_device|
          xml.contact do
            xml.c0 user.email, :type => "string"
            xml.c1 phone_device.phone, :type => "phone"
            xml.data1 "1", :type => "data_entry"
          end
        end
      end
    end
  end

end