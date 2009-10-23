require 'spec_helper'

describe Target do
  context "on create" do
    it "should store a snapshot of the audience recipients" do
      user = Factory(:user)
      audience = Factory(:audience, :users => [user])
      target = Factory(:target, :audience => audience)
      target.users.should include(user)
    end
  end
  
end
