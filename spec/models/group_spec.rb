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
  describe "validations" do
    before(:each) do
      @group=Factory(:group)
    end
      

    it "should create a new instance given valid attributes" do
      @group.should be_valid  
    end
  end
end
