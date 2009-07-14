require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Organization do
  describe "parent/child relationships" do
    it "should return an array of people from .users" do
      o=Factory(:phin_organization, :name => "APHC")
      p=Factory(:phin_person)
      o.phin_people << p
      o.phin_people.length.should == 1
    end  

  end
end
