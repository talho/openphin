# == Schema Information
#
# Table name: subscriptions
#
#  id         :integer(4)      not null, primary key
#  share_id :integer(4)
#  user_id    :integer(4)
#  owner      :boolean(1)
#  created_at :datetime
#  updated_at :datetime
#

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Subscription do
  before(:each) do
    @valid_attributes = {
      :share_id => 1,
      :user_id => 1,
      :owner => false
    }
  end

  it "should create a new instance given valid attributes" do
    Subscription.create!(@valid_attributes)
  end
end
