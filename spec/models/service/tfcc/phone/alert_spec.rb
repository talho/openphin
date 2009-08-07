require File.dirname(__FILE__) + '/../../../../spec_helper'

describe Service::TFCC::Phone::Alert do
  include Webrat::Matchers
  
  def self.should_validate_presence_of(*fields)
    fields.each do |f|
      it "should not be valid without an #{f}" do
        @tfcc_alert.send("#{f}=", nil)
        @tfcc_alert.valid?.should == false
      end
    end
  end

  subject { Service::TFCC::Phone::Alert }
  
  before(:each) do
    @alert = Factory(:alert, :acknowledge => false)
    @user = Factory(:user, :devices => [Factory(:phone_device)])
    @client_id = "AAA1"
    @user_id = "BBB2"
    @retry_duration = "6 hours"

    @tfcc_alert = subject.new(
      :alert => @alert,
      :client_id => @client_id,
      :users => [@user], 
      :user_id => @user_id, 
      :retry_duration => @retry_duration
    )
  end

  describe "validations" do
    it "should be valid" do
      @tfcc_alert.valid?.should == true
    end
    
    should_validate_presence_of :alert, :client_id, :user_id, :users
  end
  
  describe '#build!' do
    it "should return valid XML" do
      xml = @tfcc_alert.build!
      xml.should have_xpath("//ucsxml", :version => "1.1", :xmlns => "http://ucs.tfcci.com")
    end
    
    it "should include the TFCC assigned client id" do
      @tfcc_alert.client_id = "abc123"
      xml = @tfcc_alert.build!
      xml.should have_xpath("//ucsxml/request/cli_id", :content => "abc123")
    end
    
    it "should include the TFCC assigned user id" do
      @tfcc_alert.user_id = "xyz987"
      xml = @tfcc_alert.build!
      xml.should have_xpath("//ucsxml/request/usr_id", :content => "xyz987")
    end
    
    it "should include the start time" do
      start_at = Time.now
      xml = @tfcc_alert.build! start_at
      xml.should have_xpath("//ucsxml/request/activation", :start => subject.format_activation_time(start_at))
    end
    
    it "should include the stop time as the retry duration plus the start time" do
      start_at = Time.now
      @tfcc_alert.retry_duration = "4 hours"
      xml = @tfcc_alert.build! start_at
      xml.should have_xpath("//ucsxml/request/activation", :stop => subject.format_activation_time(start_at + 4.hours))
    end
    
    it "should include the alert title" do
      @tfcc_alert.alert.title = "pox outbreak"
      xml = @tfcc_alert.build!
      xml.should have_xpath("//ucsxml/request/activation/campaign/program", :desc => "pox outbreak")
    end
    
    it "should set the program channel to outdial" do
      xml = @tfcc_alert.build!
      xml.should have_xpath("//ucsxml/request/activation/campaign/program", :channel => "outdial")
    end

    context "when the alert does not require acknowledgement" do
      it "should set the program template to 0" do
        xml = @tfcc_alert.build!
        xml.should have_xpath("//ucsxml/request/activation/campaign/program", :template => "0")
      end
    end

    it "should set the program name" do
      xml = @tfcc_alert.build!
      xml.should have_xpath("//ucsxml/request/activation/campaign/program", :name => "OpenPhin Alert ##{@tfcc_alert.alert.id}")
    end

    it "should have a single text to speech slot with the alert message" do
      @tfcc_alert.alert.message = "Turkey pox outbreak"
      xml = @tfcc_alert.build!
      xml.should have_xpath("//ucsxml/request/activation/campaign/program/content/slot", :type => "TTS", :id => "1", :content => "Turkey pox outbreak")
    end
    
    it "should have a contact for each user" do
      user1 = Factory(:user, :email => "joe@example.com", :devices => [])
      user1.devices << Factory.build(:phone_device, :phone => "616-555-1212", :user => user1)

      user2 = Factory(:user, :email => "bob@example.com", :devices => [])
      user2.devices << Factory.build(:phone_device, :phone => "616-555-3939", :user => user2)
      
      @tfcc_alert.users = [user1, user2]
      $c = 1
      xml = @tfcc_alert.build!
      $c = false
      
      # user1
      xml.should have_xpath("//ucsxml/request/activation/campaign/audience/contact/c0", :type => "string", :content => "joe@example.com")
      xml.should have_xpath("//ucsxml/request/activation/campaign/audience/contact/c1", :type => "phone", :content => "616-555-1212")
      
      # user2
      xml.should have_xpath("//ucsxml/request/activation/campaign/audience/contact/c0", :type => "string", :content => "bob@example.com")
      xml.should have_xpath("//ucsxml/request/activation/campaign/audience/contact/c1", :type => "phone", :content => "616-555-3939")
    end

    context "when the alert has a voice recording" do
      before(:each) do
        @wav_file_path = "#{RAILS_ROOT}/spec/fixtures/sample.wav"
        @tfcc_alert.alert.stub(
          :message_recording =>  stub("Paperclip::Attachment", :path => @wav_file_path),
          :message_recording_file_name => "sample.wav"
        )
      end
      
      it "should include a voice slot for the audio" do
        xml = @tfcc_alert.build!
        xml.should have_xpath("//ucsxml/request/activation/campaign/program/content/slot",
          :type => "VOICE",
          :encoding => "base64",
          :format => "wav"  )
      end
      
      it "should include the base64 encoded audio file" do
        xml = Nokogiri::XML(@tfcc_alert.build!)
        (xml / "ucsxml/request/activation/campaign/program/content/slot").text.should == Base64.encode64(IO.read(@wav_file_path))
      end
    end
  
    context "when the alert does requires acknowledgement" do
      it "should set the program template to 9" do
        @tfcc_alert.alert.acknowledge = true
        xml = @tfcc_alert.build!
        xml.should have_xpath("//ucsxml/request/activation/campaign/program", :template => "9")
      end
    end
    
  end
  
end
