# == Schema Information
#
# Table name: alerts
#
#  id          :integer         not null, primary key
#  title       :string(255)
#  message     :text
#  severety    :string(255)
#  status      :string(255)
#  acknowledge :boolean
#  author_id   :integer
#  created_at  :datetime
#  updated_at  :datetime
#

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Alert do
 
  before(:each) do
    @valid_attributes = {
    }
  end
  
end
