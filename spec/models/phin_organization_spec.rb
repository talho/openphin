require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe PhinOrganization do

  before(:each) do
    @valid_attributes = {
    }
  end

  describe "parent/child relationships" do
    before(:all) do
      valid_attrs = {
        :alertingJurisdictions => '1',
        :primaryOrganizationType => '1'
      }
      @parent_dn = "ou=APHC"

      @person = PhinPerson.new(:cn => "John Smith",  :sn => "Smith", :organizations => "APHC")
      @person.save!
      @org=PhinOrganization.new({:cn=>"APHC", :ou => "APHC", :dn =>@parent_dn}.merge(valid_attrs))
      @org.uniqueMember=[@person.dn]
      @org.save!

    end
    after(:all) do
      PhinPerson.find("John Smith").delete
      PhinOrganization.find("APHC").delete
    end
    it "should return an array of people from .phin_people" do
      o=PhinOrganization.find("APHC")
      o.phin_people.length.should == 1
    end  

  end
end
