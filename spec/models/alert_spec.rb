# == Schema Information
#
# Table name: alerts
#
#  id          :integer         not null, primary key
#  title       :string(255)
#  message     :text
#  severity    :string(255)
#  status      :string(255)
#  acknowledge :boolean
#  author_id   :integer
#  created_at  :datetime
#  updated_at  :datetime
#

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Alert do
  
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

end
