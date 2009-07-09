require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe PhinOrganization do
  describe "parent/child relationships" do
    it "should return an array of people from .phin_people" do
<<<<<<< HEAD:spec/models/phin_organization_spec.rb
      org=Factory(:phin_organization)
      o=PhinOrganization.find("APHC")
=======
      o=Factory(:phin_organization, :name => "APHC")
      p=Factory(:phin_person)
      o.phin_people << p
>>>>>>> ae857bd6f25e6c38e7e4fcb8216930f991f4d98d:spec/models/phin_organization_spec.rb
      o.phin_people.length.should == 1
    end  

  end
end
