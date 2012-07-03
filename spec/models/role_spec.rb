# == Schema Information
#
# Table name: roles
#
#  id                :integer(4)      not null, primary key
#  name              :string(255)
#  description       :string(255)
#  phin_oid          :string(255)
#  created_at        :datetime
#  updated_at        :datetime
#  public            :boolean(1)
#  alerter           :boolean(1)
#  user_role         :boolean(1)      default(TRUE)
#

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Role do
  describe "finders" do
    describe "#user_roles" do
      it "should return user roles, not including system roles" do
        Role.delete_all
        user_role = FactoryGirl.create(:role, :user_role => true, :name => "user role")
        system_role = FactoryGirl.create(:role, :user_role => false, :name => "system role")
        Role.user_roles.should == [user_role]
      end
    end
  end
  
  describe "validations" do
    before(:each) do
      @role = Factory.build(:role, :name => "Public") unless @role = Role.find_by_name('Public')
    end
    
    it "should be valid" do
      @role.valid?.should be_true
    end
    
    it "should be invalid if a Role already exists with same name" do
      Role.public
      @role = Role.new(:name => "Public")
      @role.valid?.should be_false
    end
  end
end
