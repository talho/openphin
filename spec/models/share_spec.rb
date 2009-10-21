# == Schema Information
#
# Table name: shares
#
#  id          :integer(4)      not null, primary key
#  document_id :integer(4)
#  user_id     :integer(4)
#  folder_id   :integer(4)
#  created_at  :datetime
#  updated_at  :datetime
#

require 'spec_helper'

describe Share do
  before(:each) do
    @valid_attributes = {
      :document_id => 1,
      :user_id => 1,
      :folder_id => 1
    }
  end

  it "should create a new instance given valid attributes" do
    Share.create!(@valid_attributes)
  end
end
