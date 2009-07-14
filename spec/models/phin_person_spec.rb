require "spec"
require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe User do

  it "should be invalid if a Person already exists with same email" do
    p1 = Factory(:phin_person)
    p2=Factory.build(:phin_person, :email => p1.email)
    p2.valid?.should be_false
  end
  
  it "should be invalid without an email" do
    p=User.new(:id => 1, :first_name => "John", :last_name => "Smith")
    p.valid?.should == false
  end
  
  [:first_name, :last_name, :display_name, :description, :preferred_language, :title].each do |field|
    it "should make #{field} accessible" do
      User.new(field => 'foo').send(field).should == 'foo'
    end
  end
  
  describe "phin_oid" do
    it "should be generated on create" do
      Factory(:phin_person).phin_oid.should_not be_blank
    end
    
    it "should not change when saving" do
      person = Factory(:phin_person)
      lambda {
        person.update_attributes! :first_name => 'changed'
      }.should_not change { person.phin_oid }
    end
    
    it "should not allow assignment" do
      person = Factory(:phin_person)
      lambda { person.phin_oid = 1 }.should raise_error
    end
  end
end