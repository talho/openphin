require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Device do
 
  before(:each) do
    @valid_attributes = {
    }
  end

  it "should create a new instance given valid attributes" do
    PhinJurisdiction.new(@valid_attributes)
  end
  it "should return the parent node when .parent is called" do
    @parent_dn = "cn=John Smith"
    @child_dn = "cn=Email,#{@parent_dn}"
    @parent_node = PhinPerson.new(:dn => @parent_dn)
    @child_node=Device.new({:dn => @child_dn}) #stub_model(PhinJurisdiction,      :dn => @child_dn)

    PhinPerson.should_receive(:find).with("#{@parent_dn},#{@parent_node.base}").and_return(@parent_node)
    @child_node.parent.should_not be_nil
  end

end
