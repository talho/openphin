# == Schema Information
#
# Table name: rollcall_alerts
#
#  id                 :integer(4)      not null, primary key
#  severity           :integer(4)
#  type               :string(255)
#  absentee_report_id :integer(4)
#  school_id          :integer(4)
#  school_district_id :integer(4)
#  absentee_rate      :float
#  created_at         :datetime
#  updated_at         :datetime
#

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
