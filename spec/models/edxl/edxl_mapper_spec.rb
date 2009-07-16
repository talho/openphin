#require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')
#
#describe ContentObject do
##  before do
##    @message = ContentObject.parse(File.read("#{fixture_path}/PCAMessageExample.xml"), :single => true)
##  end
##
##  it "should map confidentiality" do
##    @message.confidentiality.should == 'Sensitive'
##  end
##end
#
#describe CapAlert do
#  before do
#    @message = CapAlert.parse(File.read("#{fixture_path}/PCAMessageExample.xml"), :single => true)
#  end
#
#  it "should map the identifier" do
#    @message.identifier.should == 'CDC-2006-183'
#  end
#end