class Service::Phone::TFCC::AlertWithoutAcknowledgment < Service::Phone::TFCC::Base
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

    body = ""
    xml = Builder::XmlMarkup.new :target => body, :indent => 2
    xml.instruct!
    xml.ucsxml :version=>"1.1", :xmlns=>"http://ucs.tfcci.com" do
      xml.request :method => "create" do
        xml.cli_id client_id
        xml.usr_id user_id
        xml.activation :start => start_at, :stop => stop_at do
          add_campaign(xml)
        end
      end
    end
  end
  
  private
  
  def add_campaign(xml)
    xml.campaign do |campaign|
      if alert.message_recording_file_name.blank?
        add_program_without_audio campaign
      else
        add_program_with_audio campaign
      end
      add_audience campaign
    end
  end  

  def add_program_without_audio(xml)
    xml.program :name => "OpenPhin Alert ##{alert.id}", :desc => alert.title, :channel => "outdial", :template => "0" do
      xml.addresses :address => "c0", :retry_num => "0", :retry_wait => "0"
      xml.content do
        xml.slot alert.message, :id => "1", :type => "TTS"
      end
    end
  end
  
  def add_program_with_audio(xml)
    xml.program :name => "OpenPhin Alert ##{alert.id}", :desc => alert.title, :channel => "outdial", :template => "0" do
      xml.addresses :address => "c0", :retry_num => "0", :retry_wait => "0"
      xml.content do
        xml.slot Base64.encode64(IO.read(alert.message_recording.path)), :id => "1", :type => "VOICE", :encoding => "base64", :format => "wav"
      end
     end
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