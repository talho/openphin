# == Schema Information
#
# Table name: alert_device_types
#
#  id         :integer(4)      not null, primary key
#  alert_id   :integer(4)
#  device     :string(255)
#  created_at :datetime
#  updated_at :datetime
#

require 'spec_helper'

describe AlertDeviceType do
  
  describe "device_type" do
    it "should constantize class for 'Phone'" do
      AlertDeviceType.new(:device => 'Phone').device_type.should == Service::Phone
    end
    
    it "should not do evil things" do
      lambda do
        AlertDeviceType.new(:device => 'raise "FAIL!"').device_type
      end.should raise_error(NameError)
    end
  end
end
