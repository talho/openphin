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
    @parent_dn = "ou=parent_region"
    @child_dn = "ou=some_region,#{@parent_dn}"
    @parent_node = PhinJurisdiction.new(:dn => @parent_dn)
    @child_node=PhinJurisdiction.new({:dn => @child_dn}) #stub_model(PhinJurisdiction,      :dn => @child_dn)

    PhinJurisdiction.should_receive(:find).with("#{@parent_dn},#{@parent_node.base}").and_return(@parent_node)
    @child_node.parent.should_not be_nil
  end
  it "should return nil for the parent of a root node" do
    parent_dn="ou=parent_region"
    parent_node=PhinJurisdiction.new(:dn => parent_dn)
    parent_node.parent.should be_nil
  end
  describe "parent/child relationships" do
    before(:all) do
      #debugger
      valid_attrs = {
        :alertingJurisdictions => '1',
        :primaryOrganizationType => '1'
      }
      @root_dn = "ou=Jurisdictions,dc=example,dc=org"
      @parent_dn = "ou=parent_region,#{@root_dn}"
      @another_parent_dn = "ou=another_parent_region,#{@root_dn}"
      @child_dn = "ou=child_region,#{@parent_dn}"
      @grandchild_dn = "ou=grandchild_region,#{@child_dn}"
      #root_node = PhinJurisdiction.find("Jurisdictions")
      parent_node = PhinJurisdiction.new({:dn => @parent_dn, :cn => "parent_region"}.merge(valid_attrs))
      parent_node.save
      another_parent_node = PhinJurisdiction.new({:dn => @another_parent_dn, :cn => "another_parent_region"}.merge(valid_attrs))
      another_parent_node.save
      child_node = PhinJurisdiction.new({:dn => @child_dn, :cn => "child_region"}.merge(valid_attrs))
      child_node.save
      grandchild_node = PhinJurisdiction.new({:dn => @grandchild_dn, :cn => "grandchild_region"}.merge(valid_attrs))
      grandchild_node.save
      @root = PhinJurisdiction.find("parent_region")
    end
    after(:all) do
      [
        "grandchild_region",
        "child_region",
        "another_parent_region",
        "parent_region"
      ].each{|region| PhinJurisdiction.find(region).delete }
    end
    it "should return an array of child jurisdictions of the active jurisdiction with recursion" do
      @root.jurisdictions(true).length.should == 2
    end
    it "should return an array of child jurisdictions of the active jurisdiction without recursion" do
      @root.jurisdictions(false).length.should == 1
    end
    
  end
end
