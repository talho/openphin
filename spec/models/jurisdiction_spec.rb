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
  
  describe "associations" do
    it "should have many users through its role memberships" do
      jurisdiction = Factory(:jurisdiction)
      Factory(:jurisdiction).move_to_child_of(jurisdiction)
      other_jurisdiction = Factory(:jurisdiction)
      user1 = Factory(:user)
      user2 = Factory(:user)
      unexpected_user = Factory(:user)
      
      Factory(:role_membership, :jurisdiction => jurisdiction, :user => user1)
      Factory(:role_membership, :jurisdiction => jurisdiction, :user => user2)
      Factory(:role_membership, :jurisdiction => other_jurisdiction, :user => unexpected_user)
      
      jurisdiction.users.should == [user1, user2]
    end
    
    it "should not include users in child jurisdictions" do
      jurisdiction = Factory(:jurisdiction)
      other_jurisdiction = Factory(:jurisdiction)
      other_jurisdiction.move_to_child_of(jurisdiction)
      user1 = Factory(:user)
      user2 = Factory(:user)
      unexpected_user = Factory(:user)
      
      Factory(:role_membership, :jurisdiction => jurisdiction, :user => user1)
      Factory(:role_membership, :jurisdiction => jurisdiction, :user => user2)
      Factory(:role_membership, :jurisdiction => other_jurisdiction, :user => unexpected_user)
      
      jurisdiction.users.should == [user1, user2]
       
    end
  end
  
  describe "name_scope: admin relationships" do
    before :each do
      @dallas = Factory(:jurisdiction, :name => "dallas")
      @houston = Factory(:jurisdiction, :name => "houston")
      @austin = Factory(:jurisdiction, :name => "austin")
      @user = Factory(:user)
      @user.role_memberships << Factory(:role_membership, :jurisdiction => @dallas, :role => Role.admin, :user => @user)
      @user.role_memberships << Factory(:role_membership, :jurisdiction => @houston, :role => Role.admin, :user => @user)
      @user.role_memberships << Factory(:role_membership, :jurisdiction => @austin, :role => Factory(:role), :user => @user)
    end

    it "should return jurisdictions the user is an admin of" do
      @user.jurisdictions.admin.should == [@dallas, @houston]
    end
    
    it "should not return any jurisdictions the user is not an admin of" do
      @user.jurisdictions.admin.should_not include(@austin)
    end
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

# == Schema Information
#
# Table name: jurisdictions
#
#  id                     :integer(4)      not null, primary key
#  name                   :string(255)
#  phin_oid               :string(255)
#  description            :string(255)
#  fax                    :string(255)
#  locality               :string(255)
#  postal_code            :string(255)
#  state                  :string(255)
#  street                 :string(255)
#  phone                  :string(255)
#  county                 :string(255)
#  alerting_jurisdictions :string(255)
#  parent_id              :integer(4)
#  lft                    :integer(4)
#  rgt                    :integer(4)
#  created_at             :datetime
#  updated_at             :datetime
#  fips_code              :string(255)
#  foreign                :boolean(1)      default(FALSE), not null
#

