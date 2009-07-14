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
  
  describe "status" do
    ['Actual', 'Exercise', 'Test'].each do |status|
      it "should be valid with #{status.inspect}" do
        alert = Factory.build(:alert, :status => status)
        alert.should be_valid
      end
    end

    [nil, '', 'Shout Out'].each do |status|
      it "should be invalid with #{status.inspect}" do
        alert = Factory.build(:alert, :status => status)
        alert.should_not be_valid
        alert.errors.on(:status).should_not be_nil
      end
    end
  end

end
