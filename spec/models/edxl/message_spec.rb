require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe EDXL::Message do
  before do
    @message = EDXL::Message.parse(File.read("#{fixture_path}/PCAMessageAlert.xml"))
  end
  
  it "should have alerts" do
    @message.alerts.size.should == 1
  end
  
  it "should map distribution_id" do
    @message.distribution_id.should == 'CDC-2006-183'
  end
end
