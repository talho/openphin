# == Schema Information
#
# Table name: group_snapshots
#
#  id         :integer(4)      not null, primary key
#  group_id   :integer(4)
#  alert_id   :integer(4)
#  created_at :datetime
#  updated_at :datetime
#

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
