# == Schema Information
#
# Table name: devices
#
#  id            :integer         not null, primary key
#  user_id       :integer
#  type          :string(255)
#  description   :string(255)
#  name          :string(255)
#  coverage      :string(255)
#  emergency_use :boolean
#  home_use      :boolean
#  options       :text
#

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Device do
 
  before(:each) do
    @valid_attributes = {
    }
  end

  it "should create a new instance given valid attributes" do
    Jurisdiction.new(@valid_attributes)
  end
  it "should return the parent node when .parent is called" do
    @parent_node = User.new(:id => 1, :first_name => "John", :last_name => "Smith")
    @child_node=Device.new(:id => 2, :user => @parent_node, :name => "Email") #stub_model(PhinJurisdiction,      :dn => @child_dn)

    #User.should_receive(:find).with(1).and_return(@parent_node)
    @child_node.parent.should_not be_nil
  end

end
