# == Schema Information
#
# Table name: alerts
#
#  id                     :integer         not null, primary key
#  title                  :string(255)
#  message                :text
#  severity               :string(255)
#  status                 :string(255)
#  acknowledge            :boolean
#  author_id              :integer
#  created_at             :datetime
#  updated_at             :datetime
#  sensitive              :boolean
#  delivery_time          :integer
#  sent_at                :datetime
#  message_type           :string(255)
#  program_type           :string(255)
#  from_organization_id   :integer
#  from_organization_name :string(255)
#  from_organization_oid  :string(255)
#  identifier             :string(255)
#  scope                  :string(255)
#  category               :string(255)
#  program                :string(255)
#  urgency                :string(255)
#  certainty              :string(255)
#  jurisdictional_level   :string(255)
#  references             :string(255)
#  from_jurisdiction_id   :integer
#  original_alert_id      :integer
#

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Alert do

  describe 'class level builders' do
    describe '.build_cancellation' do
      def fields_not_cloned
        ["id", "updated_at", "created_at", "title", "message_type", "original_alert_id"]
      end
      
      def changeable_fields
        ["message", "severity", "sensitive"]
      end
      
      it "should build a new alert given an existing alert" do
        alert = Factory(:alert)
        new_alert = alert.build_cancellation
        new_alert.should_not == alert
        new_alert.new_record?.should be_true
      end
      
      it "should assign the original alert to the existing alert" do
        alert = Factory(:alert)
        new_alert = alert.build_cancellation
        new_alert.original_alert.should == alert
        new_alert.save!
        new_alert.reload.original_alert.should == alert
      end
      
      it "should set the message_type to 'Cancel'" do
        alert = Factory(:alert)
        new_alert = alert.build_cancellation
        new_alert.save!
        new_alert.reload.message_type.should == "Cancel"
      end
      
      it "should clone values from the existing alert" do
        alert = Factory(:alert)
        new_alert = alert.build_cancellation
        new_alert.attributes.except(*fields_not_cloned).should == alert.attributes.except(*fields_not_cloned)
      end
      
      it "should prefix the title with '[Cancel] -'" do
        alert = Factory(:alert, :title => "Hey there!")
        alert.build_cancellation.title.should == "[Cancel] - Hey there!"
      end
      
      it "should allow message to be changed" do
        alert = Factory(:alert, :message => "test")
        new_alert = alert.build_cancellation(:message => "Mic check")
        new_alert.message.should == "Mic check"
      end
      
      it "should allow severity to be changed" do
        alert = Factory(:alert, :severity => Alert::Severities.first)
        new_alert = alert.build_cancellation(:severity => Alert::Severities.last)
        new_alert.severity.should == Alert::Severities.last
      end

      it "should allow sensitive to be changed" do
        alert = Factory(:alert, :sensitive => true)
        new_alert = alert.build_cancellation(:sensitive => false)
        new_alert.sensitive.should be_false
      end
      
      it "should ignore changes to status" do
        alert = Factory(:alert, :status => Alert::Statuses.first)
        new_alert = alert.build_cancellation(:status => Alert::Statuses.last)
        new_alert.status.should == Alert::Statuses.first
      end
      
      [:references, :category, :urgency, :scope, 
       :from_organization_name, :delivery_time, :program_type, :jurisdictional_level, 
       :acknowledge, :from_organization_id, :certainty, :program, :from_organization_oid, 
       :from_jurisdiction_id, :author_id
      ].each do |field|
        it "should ignore changes to #{field}" do
          old_value, new_value = case Alert.columns_hash[field.to_s].type
            when :datetime
              [Date.today, Date.yesterday]
            when :string, :text
              ["value1", "value2"]
            when :integer
              [15, 60]
            when :boolean
              [false, true]
            else
              raise "unknown field #{field} or maybe its misspelled?"
          end
          alert = Factory(:alert, field => old_value)
          new_alert = alert.build_cancellation(field => old_value)
          new_alert.send(field).should == old_value
        end        
      end

    end
  end
  
  describe "status" do
    ['Actual', 'Exercise', 'Test'].each do |status|
      it "should be valid with #{status.inspect}" do
        alert = Factory.build(:alert, :status => status)
        alert.should be_valid
      end
    end

    [nil, '', 'Shout Out'].each do |status|
      it "should be invalid with #{status.inspect}" do
        alert = Factory.build(:alert, :status => status)
        alert.should_not be_valid
        alert.errors.on(:status).should_not be_nil
      end
    end
  end
  
  describe "severity" do
    ['Extreme', 'Severe', 'Moderate', 'Minor', 'Unknown'].each do |severity|
      it "should be valid with #{severity.inspect}" do
        alert = Factory.build(:alert, :severity => severity)
        alert.valid?
        alert.should be_valid
      end
    end

    [nil, '', 'Bogus'].each do |severity|
      it "should be invalid with #{severity.inspect}" do
        alert = Factory.build(:alert, :severity => severity)
        alert.should_not be_valid
        alert.errors.on(:severity).should_not be_nil
      end
    end
  end
  
  describe "delivery_time" do
    [15, 60, 1440, 4320].each do |delivery_time|
      it "should be valid with #{delivery_time.inspect}" do
        alert = Factory.build(:alert, :delivery_time => delivery_time)
        alert.valid?
        alert.should be_valid
      end
    end

    [nil, '', 'Bogus', 0].each do |delivery_time|
      it "should be invalid with #{delivery_time.inspect}" do
        alert = Factory.build(:alert, :delivery_time => delivery_time)
        alert.should_not be_valid
        alert.errors.on(:delivery_time).should_not be_nil
      end
    end
  end
  
  describe "acknowledge" do
    it "should default to true" do
      a = Alert.new
      a.acknowledge?.should == true
    end
    
    it "should allow override" do
      Alert.new(:acknowledge => false).acknowledge?.should == false
    end
  end
  
  describe "device_types=" do
    before do
      @alert = Factory(:alert)
    end

    it "should create an association for the given device types" do
      @alert.device_types = ['Device::EmailDevice']
      lambda { @alert.save }.should change { @alert.alert_device_types.count }
    end
    
    it "should create an association for the given device types" do
      @alert.alert_device_types.create! :device => 'Device::EmailDevice'
      @alert.device_types = []
      @alert.alert_device_types.count.should == 0
    end
  end
  
  describe "device_types" do
    before do
      @alert = Factory(:alert)
    end

    it "should return the names of the device types" do
      @alert.alert_device_types.create! :device => 'Device::EmailDevice'
      @alert.device_types.should == ['Device::EmailDevice']
    end
  end
  
  describe "message_type" do
    before do
      @alert = Factory(:alert)
    end
    
    it "should have a default of 'Alert'" do
      @alert.message_type.should == 'Alert'
    end
  end

end
