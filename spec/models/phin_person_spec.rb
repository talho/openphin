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
      @p1 = stub_model(PhinPerson, :id => 1, :first_name => "John", :last_name => "Smith", :email => "js@example.com")
      @p1 = stub_model(PhinPerson, :id => 2, :first_name => "John", :last_name => "Smith", :email => "js@example.com")
      p=PhinPerson.new(@p1)
      p.save.should be true
      p=PhinPerson.new(@p2)
      p.save.should be_false
      
    end
    it "should not create a new Person without an email attribute" do
      p=PhinPerson.new(:id => 1, :first_name => "John", :last_name => "Smith")
      p.valid?.should == false
    end
  end
    
end