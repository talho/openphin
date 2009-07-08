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
          :last_name => "Smith",
       }
      PhinPerson.new(@valid_attrs).save!
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