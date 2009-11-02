# == Schema Information
#
# Table name: schools
#
#  id            :integer(4)      not null, primary key
#  name          :string(255)
#  display_name  :string(255)
#  level         :string(255)
#  address       :string(255)
#  postal_code   :string(255)
#  school_number :integer(4)
#  district_id   :integer(4)
#  created_at    :datetime
#  updated_at    :datetime
#  region        :string(255)
#

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe School do
  before(:each) do
    @valid_attributes = {
      
    }
  end

  it "should create a new instance given valid attributes" do
    School.create!(@valid_attributes)
  end
end
