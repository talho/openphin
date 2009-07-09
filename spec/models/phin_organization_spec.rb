require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe PhinOrganization do


  describe "parent/child relationships" do

    it "should return an array of people from .phin_people" do
      o=PhinOrganization.find("APHC")
      o.phin_people.length.should == 1
    end  

  end
end
