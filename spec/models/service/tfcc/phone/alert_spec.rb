require File.expand_path(File.dirname(__FILE__) + '/../../../../spec_helper')

describe Service::TFCC::Phone::Alert do
  include Webrat::Matchers
  extend SpecHelpers::TFCCAlertMacros
  
  def self.should_validate_presence_of(*fields)
    fields.each do |f|
      it "should not be valid without an #{f}" do
        @tfcc_alert.send("#{f}=", nil)
        @tfcc_alert.valid?.should == false
      end
    end
  end

  before(:each) do
    @alert = Factory(:alert, :acknowledge => false)
    @user = Factory(:user, :devices => [Factory(:phone_device)])
    @client_id = "AAA1"
    @user_id = "BBB2"
    @retry_duration = "6 hours"

    @tfcc_alert = Service::TFCC::Phone::Alert.new(
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
    subject { @tfcc_alert }
    
    should_return_valid_tfcc_xml
    should_include_tfcc_assigned_client_id
    should_include_tfcc_assigned_user_id
    should_include_activation_start_time
    should_include_activation_stop_time
    should_set_program_description_to_alert_title
    should_set_program_channel_to_outdial
    should_set_program_name

    should_include_TTS_slot_with_alert_message
    should_include_audience_contact_for_each_user
    
    context "when the alert has a voice recording" do
      before(:each) do
        subject.alert.stub(
          :message_recording =>  stub("Paperclip::Attachment", :path => "#{RAILS_ROOT}/spec/fixtures/sample.wav"),
          :message_recording_file_name => "sample.wav"
        )
      end
      
      should_include_voice_slot_for_audio
      should_include_base64_encoded_audio_file
    end
  
    context "when the alert does not require acknowledgement" do
      before(:each){ subject.alert.acknowledge = false }

      should_set_the_program_template_to "0"
    end
    
    context "when the alert does require acknowledgement" do
      before(:each){ subject.alert.acknowledge = true }

      should_set_the_program_template_to "9"
      should_include_TTS_slots_for_acknowledgement
    end
    
  end
  
end
