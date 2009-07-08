require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe PhinJurisdiction do
 
  before(:each) do
    @valid_attributes = {
    }
  end

  it "should create a new instance given valid attributes" do
    PhinJurisdiction.new(@valid_attributes)
  end
  it "should return the parent node when .parent is called" do
    @parent_node = stub_model(PhinJurisdiction, :id => "1", :name => "Parent")
    PhinJurisdiction.should_receive(:find).with(1).and_return(@parent_node)
    @child_node=stub_model(PhinJurisdiction, :parent_id => "1", :id => "2", :name => "Child")
    @child_node.parent.should_not be_nil
  end
  it "should return nil for the parent of a root node" do
    parent_dn="ou=parent_region"
    parent_node=PhinJurisdiction.new(:dn => parent_dn)
    parent_node.parent.should be_nil
  end
  #describe "parent/child relationships" do
  #  it "should return an array of child jurisdictions of the active jurisdiction with recursion" do
  #    @root.jurisdictions(true).length.should == 2
  #  end
  #  it "should return an array of child jurisdictions of the active jurisdiction without recursion" do
  #    @root.jurisdictions(false).length.should == 1
  #  end
  #
  #end
end
