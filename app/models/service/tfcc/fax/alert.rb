class Service::Tfcc::Fax::Alert < Service::Tfcc::Fax::Base
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
    xml.program :name => "TXPhin Alert ##{alert.id}", :desc => alert.title, :channel => "fax", :template => "0", :subject => alert.title, :from => "#{alert.author.display_name} in #{alert.from_jurisdiction.name}" do
      xml.addresses :address => "c1", :retry_num => "0", :retry_wait => "0"
      xml.content do
        xml.slot alert.message, :id => "1"
      end
    end
  end

  def add_audience(xml)
    xml.audience do 
      users.each do |user|
        user.devices.fax.each do |fax_device|
          xml.contact do
            xml.c0 user.email, :type => "string"
            xml.c1 fax_device.fax, :type => "phone"
          end
        end
      end
    end
  end

end