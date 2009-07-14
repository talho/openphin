# == Schema Information
#
# Table name: roles
#
#  id                :integer         not null, primary key
#  name              :string(255)
#  description       :string(255)
#  phin_oid          :string(255)
#  created_at        :datetime
#  updated_at        :datetime
#  approval_required :boolean
#  alerter           :boolean
#

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Role do
  before(:each) do
    @valid_attributes = {
      :name => "value for name",
      :approval_required => false
    }
  end

  it "should create a new instance given valid attributes" do
    Role.create!(@valid_attributes)
  end
end
