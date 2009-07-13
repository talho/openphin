require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe PhinPersonProfile do
  before(:each) do
    @valid_attributes = {
      # :photo => ,
      :public => false,
      :credentials => "value for credentials",
      :employer => "value for employer",
      :experience => "value for experience",
      :bio => "value for bio"
    }
  end

  it "should create a new instance given valid attributes" do
    PhinPersonProfile.create!(@valid_attributes)
  end
end
