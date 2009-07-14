require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Organization do
  describe "parent/child relationships" do
    it "should return an array of people from .users" do
      o=Factory(:organization, :name => "APHC")
      p=Factory(:user)
      o.users << p
      o.users.length.should == 1
    end  

  end
end
