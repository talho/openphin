require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe PhinRole do
  before(:each) do
    @valid_attributes = {
      :name => "value for name",
      :approval_required => false
    }
  end

  it "should create a new instance given valid attributes" do
    PhinRole.create!(@valid_attributes)
  end
end
