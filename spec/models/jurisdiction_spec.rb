# == Schema Information
#
# Table name: jurisdictions
#
#  id                        :integer         not null, primary key
#  name                      :string(255)
#  phin_oid                  :string(255)
#  description               :string(255)
#  fax                       :string(255)
#  locality                  :string(255)
#  postal_code               :string(255)
#  state                     :string(255)
#  street                    :string(255)
#  phone                     :string(255)
#  county                    :string(255)
#  alerting_jurisdictions    :string(255)
#  primary_organization_type :string(255)
#  parent_id                 :integer
#  lft                       :integer
#  rgt                       :integer
#  type                      :string(255)
#  created_at                :datetime
#  updated_at                :datetime
#

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Jurisdiction do
 
  before(:each) do
    @valid_attributes = {
    }
  end

  it "should create a new instance given valid attributes" do
    Jurisdiction.new(@valid_attributes)
  end

  it "should return the parent node when .parent is called" do
    @parent_node = stub_model(Jurisdiction, :id => 1, :name => "Parent")
    #PhinJurisdiction.should_receive(:find).with(1).and_return(@parent_node)
    @child_node=stub_model(Jurisdiction, :parent => @parent_node, :id => 2, :name => "Child")
    @child_node.parent.should_not be_nil
    @child_node.parent.should == @parent_node
  end
  
  it "should return nil for the parent of a root node" do
    parent_node=Jurisdiction.new(:id => 3, :name => "Parent")
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
