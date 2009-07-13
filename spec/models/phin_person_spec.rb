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
    
    it "should not create a new Person if one already exists with same email" do
      p1 = Factory(:phin_person)
      p2=Factory.build(:phin_person, :email => p1.email)
      p2.valid?.should be_false
      #p1=stub_model(PhinPerson, :email => "j@e.com")
      #PhinPerson.stub!(:find).and_return(p1)
      #p2=PhinPerson.new(:email => "j@e.com")
      #p2.valid?.should be_false
    end
    it "should not create a new Person without an email attribute" do
      p=PhinPerson.new(:id => 1, :first_name => "John", :last_name => "Smith")
      p.valid?.should == false
    end
  end
    
end