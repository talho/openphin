class Service::Phone::AlertWithoutAcknowledgmentBuilder
  
  def self.build(options)
    alert, user, device = options[:alert], options[:user], options[:device]
    client_id, user_id = options[:client_id], options[:user_id]
    retry_duration = options[:retry_duration].scan(/\d+/).first.to_i.hours
    
    body = ""
    xml = Builder::XmlMarkup.new :target => body, :indent => 2
    xml.instruct!
    xml.ucsxml :version=>"1.1", :xmlns=>"http://ucs.tfcci.com" do |ucsxml|
      ucsxml.request :method => "create" do |request|
        request.cli_id client_id
        request.usr_id user_id
        request.activation :start => Time.now.strftime("%Y%m%d%H%M%S"), :stop => (Time.now + retry_duration).strftime("%Y%m%d%H%M%S") do |activation|
          activation.campaign do |campaign|
            
            campaign.program :name => "OpenPhin Alert ##{alert.id}", :desc => alert.title, :channel => "outdial", :template => "0" do |program|
              program.addresses :address => "c0", :retry_num => "0", :retry_wait => "0"
              program.content do |content|
                msg = alert.message
                content.slot msg, :id => "1", :type => "TTS" 
              end
            end

            campaign.audience do |audience|
              audience.contact do |contact|
                contact.c0 device.phone, :type => "phone" 
              end
            end

          end
        end
      end
    end
  end
  
end