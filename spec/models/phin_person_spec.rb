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
          :organizations => "talho"
       }
      PhinPerson.new(@valid_attrs).save!
    end
    after(:all) do
      PhinPerson.find("John Smith").delete
    end
    it "should not create a new Person if one already exists" do

      p2=PhinPerson.new(@valid_attrs)
      p2.save.should be_false
      
    end
  end
  describe "mapping to XML" do
    it "should provide a mapper object through the .mapper method" do
      p=PhinPerson.new(:cn =>"J S", :sn =>"S", :organizations =>"talho")
      p.mapper.should_not be_nil
    end
    it "should have the required properties set on the mapper"

  end
  
end