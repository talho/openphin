module SpecHelpers
  module TfccAlertMacros
    def should_return_valid_tfcc_xml
      it "should return valid XML" do
        xml = subject.build!
        xml.should have_xpath("//ucsxml", :version => "1.1", :xmlns => "http://ucs.tfcci.com")
      end
    end
    
    def should_include_tfcc_assigned_client_id
      it "should include the TFCC assigned client id" do
        subject.client_id = "abc123"
        xml = subject.build!
        xml.should have_xpath("//ucsxml/request/cli_id", :content => "abc123")
      end
    end
    
    def should_include_tfcc_assigned_user_id
      it "should include the TFCC assigned user id" do
        subject.user_id = "xyz987"
        xml = subject.build!
        xml.should have_xpath("//ucsxml/request/usr_id", :content => "xyz987")
      end
    end
    
    def should_include_activation_start_time
      it "should include the start time" do
        start_at = Time.now
        xml = subject.build! start_at
        xml.should have_xpath("//ucsxml/request/activation", :start => subject.class.format_activation_time(start_at))
      end
    end
    
    def should_include_activation_stop_time
      it "should include the stop time as the retry duration plus the start time" do
        start_at = Time.now
        subject.retry_duration = "4 hours"
        xml = subject.build! start_at
        xml.should have_xpath("//ucsxml/request/activation", :stop => subject.class.format_activation_time(start_at + 4.hours))
      end
    end

    def should_set_program_description_to_alert_title
      it "should include the alert title as the program description" do
        subject.alert.title = "pox outbreak"
        xml = subject.build!
        xml.should have_xpath("//ucsxml/request/activation/campaign/program", :desc => "pox outbreak")
      end
    end
    
    def should_set_program_channel_to_outdial
      it "should set the program channel to outdial" do
        xml = subject.build!
        xml.should have_xpath("//ucsxml/request/activation/campaign/program", :channel => "outdial")
      end
    end

    def should_set_program_name
      it "should set the program name" do
        xml = subject.build!
        xml.should have_xpath("//ucsxml/request/activation/campaign/program", :name => "TXPhin Alert ##{subject.alert.id}")
      end
    end
    
    def should_include_TTS_slot_with_alert_message
      it "should have a single text to speech slot with the alert message" do
        subject.alert.short_message = "Turkey pox outbreak"
        xml = subject.build!
        xml.should have_xpath("//ucsxml/request/activation/campaign/program/content/slot", :type => "TTS", :id => "1", :content => "Turkey pox outbreak")
      end
    end
   
    def should_include_audience_contact_for_each_user
      it "should have a contact for each user" do
        users = []
        5.times do |i|
          users << FactoryGirl.create(:user, :email => "joe#{i}@example.com", :devices => [])
          users.last.devices << Factory.build(:phone_device, :phone => "616555#{i.to_s.rjust(4,'0')}", :user => users.last)
        end

        subject.users = users
        xml = subject.build!

        5.times do |i|
          xml.should have_xpath("//ucsxml/request/activation/campaign/audience/contact/c0", :type => "string", :content => "joe#{i}@example.com")
          xml.should have_xpath("//ucsxml/request/activation/campaign/audience/contact/c1", :type => "phone", :content => "616555#{i.to_s.rjust(4,'0')}")
        end
      end
    end
    
    def should_include_voice_slot_for_audio
      it "should include a voice slot for the audio" do
        xml = subject.build!
        xml.should have_xpath("//ucsxml/request/activation/campaign/program/content/slot",
          :type => "VOICE",
          :encoding => "base64",
          :format => "wav"  )
      end
    end
    
    def should_include_base64_encoded_audio_file
      it "should include the base64 encoded audio file" do
        xml = Nokogiri::XML(subject.build!)
        node = (xml / "ucsxml/request/activation/campaign/program/content/slot")
        node.text.should == Base64.encode64(IO.read(subject.alert.message_recording.path))
      end
    end
   
    def should_set_the_program_template_to(n)
      it "should set the program template to 0" do
        xml = subject.build!
        xml.should have_xpath("//ucsxml/request/activation/campaign/program", :template => n)
      end
    end
    
    def should_include_TTS_slots_for_acknowledgement
      it "should include a slots for the options to acknowledge the alert" do
        xml = subject.build!
        path = "//ucsxml/request/activation/campaign/program/content/slot"
        xml.should have_xpath(path.dup, :type => "TTS", :id => "2", :content => "You have received a Health Alert.  Please login to the Health Alert Network Application to view the alert message.")
        xml.should have_xpath(path.dup, :type => "TTS", :id => "3", :content => "Please press one to acknowledge this health alert.")
        xml.should have_xpath(path.dup, :type => "TTS", :id => "4", :content => "The number pressed is not valid.  Please press one to acknowledge this health alert.")
        xml.should have_xpath(path.dup, :type => "TTS", :id => "5", :content => "You have failed to acknowledge this message.  Good-bye.")
        xml.should have_xpath(path.dup, :type => "TTS", :id => "6", :content => "You have successfully acknowledged this health alert.  Thanks for your cooperation.  Good-bye.")
      end
    end
  end
end