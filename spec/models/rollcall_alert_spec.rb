require 'spec_helper'

describe RollcallAlert do
  before(:each) do
    @valid_attributes = {
      :absentee_report_id => 1,
      :severity => 1
    }
  end

  it "should create a new instance given valid attributes" do
    RollcallAlert.create!(@valid_attributes)
  end
end
