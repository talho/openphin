# == Schema Information
#
# Table name: groups
#
#  id         :integer(4)      not null, primary key
#  name       :string(255)
#  owner_id   :integer(4)
#  scope      :string(255)
#  created_at :datetime
#  updated_at :datetime
#

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Group do
  before(:each) do
    jurisdiction = Factory(:jurisdiction)
    Factory(:jurisdiction).move_to_child_of(jurisdiction)
    @valid_attributes = {
      :owner_id => Factory(:user).id,
      :scope => "Personal"
    }
  end

  it "should create a new instance given valid attributes" do
    Group.create!(@valid_attributes)
  end
end
