require "spec"
require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe "PhinPerson rules" do

  ## Called before each example.
  #before(:each) do
  #  # Do nothing
  #end
  #
  ## Called after each example.
  #after(:each) do
  #  # Do nothing
  #end
  describe "creating PhinPeople" do
    before(:all) do
       @valid_attrs = {
          :sn => "Smith",
          :cn => "John Smith",
          :organizations => "talho",
          :dn => "externalUID=#{PHIN_OID_ROOT}.1.1"
       }
      PhinPerson.new(@valid_attrs).save!
    end
    after(:all) do
      PhinPerson.find(:first, :attribute => 'cn', :value => "John Smith").delete
    end
    it "should not create a new Person if one already exists" do

      p2=PhinPerson.new(@valid_attrs)
      p2.save.should be_false
      
    end
    it "should not create a new Person without an externalUID set" do
      p=PhinPerson.new(:sn => "test", :cn =>"fullname", :organizations => "talho", :dn => "givenName=10")
      p.valid?.should == false
    end
  end
    
end