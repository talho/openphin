# == Schema Information
#
# Table name: audiences
#
#  id                    :integer(4)      not null, primary key
#  name                  :string(255)
#  owner_id              :integer(4)
#  scope                 :string(255)
#  created_at            :datetime
#  updated_at            :datetime
#  owner_jurisdiction_id :integer(4)
#  type                  :string(255)
#

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Group do

  describe "validations" do
    before(:each) do
      @jurisdiction = Factory(:jurisdiction)
      Factory(:jurisdiction).move_to_child_of(@jurisdiction)
      @group=Factory(:group, :users => [Factory(:user)])
    end

    it "be valid" do
      @group.should be_valid
    end
  end
end
