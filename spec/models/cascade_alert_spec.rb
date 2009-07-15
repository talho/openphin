require File.dirname(__FILE__) + '/../spec_helper'

describe CascadeAlert do
  before do
    @cascade_alert = CascadeAlert.new(Alert.new)
  end
  
  describe 'to_edxl' do
    
    it "should not blow up" do
      lambda {@cascade_alert.to_edxl}.should_not raise_error
    end
    
    it "should be a valid document"
    
    it "should wrap everything in an EDXLDistribution tag"
  end
end
