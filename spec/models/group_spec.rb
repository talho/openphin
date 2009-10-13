require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Group do
  before(:each) do
    jurisdiction = Factory(:jurisdiction)
    Factory(:jurisdiction).move_to_child_of(jurisdiction)
    @valid_attributes = {
      :owner_id => Factory(:user).id
    }
  end

  it "should create a new instance given valid attributes" do
    Group.create!(@valid_attributes)
  end
end
