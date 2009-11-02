# == Schema Information
#
# Table name: targets
#
#  id          :integer(4)      not null, primary key
#  audience_id :integer(4)
#  item_id     :integer(4)
#  item_type   :string(255)
#  created_at  :datetime
#  updated_at  :datetime
#  creator_id  :integer(4)
#

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Target do
  context "on create" do
    before do
      @user = user = Factory(:user)
      @audience = Factory(:audience, :users => [user])
    end
    
    it "should store a snapshot of the audience recipients" do
      Factory(:target, :audience => @audience).users.should include(@user)
    end
    
    it "should not include public users if item specifies not to" do
      item = mock_model(Document, :include_public_users? => false)
      target = Factory(:target, :audience => @audience, :item => item)
      target.users.should_not include(@user)
    end

    it "should include public users if item specifies to" do
      item = mock_model(Alert, :include_public_users? => true)
      target = Factory(:target, :audience => @audience, :item => item)
      target.users.should include(@user)
    end
  end
  
end
