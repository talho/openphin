class Service::Phone::AlertWithAcknowledgmentBuilder
  
  def self.build(options)
    users = []
    alert = options[:alert]
    client_id, user_id = options[:client_id], options[:user_id]
    users << {:user => options[:user], :device => options[:device]} if !options[:user].blank? && !options[:device].blank? 
    retry_duration = options[:retry_duration].scan(/\d+/).first.to_i.hours
    
    if users.size == 0
      alert.alert_attempts.with_device('Device::PhoneDevice').each do |alert_attempt|
        alert_attempt.user.devices.phone.each do |device|
          users << {:user => alert_attempt.user, :device => device}
        end
      end
    end


    body = ""
    xml = Builder::XmlMarkup.new :target => body, :indent => 2
    xml.instruct!
    xml.ucsxml :version=>"1.1", :xmlns=>"http://ucs.tfcci.com" do |ucsxml|
      ucsxml.request :method => "create" do |request|
        request.cli_id client_id
        request.usr_id user_id
        request.activation :start => Time.now.strftime("%Y%m%d%H%M%S"), :stop => (Time.now + retry_duration).strftime("%Y%m%d%H%M%S") do |activation|
          activation.campaign do |campaign|
            
            if alert.message_recording_file_name.blank?
              campaign.program :name => "OpenPhin Alert ##{alert.id}", :desc => alert.title, :channel => "outdial", :template => "9" do |program|
                program.addresses :address => "c1", :retry_num => "0", :retry_wait => "600"
                program.content do |content|
                  msg = alert.message
                  content.slot msg, :id => "1", :type => "TTS"
                  msg = "You have received a Health Alert.  Please login to the Health Alert Network Application to view the alert message."
                  content.slot msg, :id => "2", :type => "TTS"
                  msg = "Please press one to acknowledge this health alert."
                  content.slot msg, :id => "3", :type => "TTS"
                  msg = "The number pressed is not valid.  Please press one to acknowledge this health alert."
                  content.slot msg, :id => "4", :type => "TTS"
                  msg = "You have failed to acknowledge this message.  Good-bye."
                  content.slot msg, :id => "5", :type => "TTS"
                  msg = "You have successfully acknowledged this health alert.  Thanks for your cooperation.  Good-bye."
                  content.slot msg, :id => "6", :type => "TTS"
                end
              end
            else
              campaign.program :name => "OpenPhin Alert ##{alert.id}", :desc => alert.title, :channel => "outdial", :template => "9" do |program|
                program.addresses :address => "c1", :retry_num => "0", :retry_wait => "600"
                program.content do |content|
                  msg = alert.message
                  content.slot Base64.encode64(IO.read(alert.message_recording.path)), :id => "1", :type => "VOICE", :encoding => "base64", :format => "wav"
                  msg = "You have received a Health Alert.  Please login to the Health Alert Network Application to view the alert message."
                  content.slot msg, :id => "2", :type => "TTS"
                  msg = "Please press one to acknowledge this health alert."
                  content.slot msg, :id => "3", :type => "TTS"
                  msg = "The number pressed is not valid.  Please press one to acknowledge this health alert."
                  content.slot msg, :id => "4", :type => "TTS"
                  msg = "You have failed to acknowledge this message.  Good-bye."
                  content.slot msg, :id => "5", :type => "TTS"
                  msg = "You have successfully acknowledged this health alert.  Thanks for your cooperation.  Good-bye."
                  content.slot msg, :id => "6", :type => "TTS"
                end
               end
             end

            campaign.audience do |audience|
              users.each do |user|
                audience.contact do |contact|
                  contact.c0 user[:user].email, :type => "string"
                  contact.c1 user[:device].phone, :type => "phone"
                  contact.data1 "1", :type => "data_entry"
                end
              end
            end

          end
        end
      end
    end
  end
  
end