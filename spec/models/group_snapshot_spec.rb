require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe GroupSnapshot do
  before(:each) do
    @valid_attributes = {
      :group_id => 1
    }
  end

  it "should create a new instance given valid attributes" do
    GroupSnapshot.create!(@valid_attributes)
  end
end
