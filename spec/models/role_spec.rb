# == Schema Information
#
# Table name: roles
#
#  id                :integer         not null, primary key
#  name              :string(255)
#  description       :string(255)
#  phin_oid          :string(255)
#  created_at        :datetime
#  updated_at        :datetime
#  approval_required :boolean
#  alerter           :boolean
#  user_role         :boolean         default(TRUE)
#

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Role do
  describe "finders" do
    describe "#user_roles" do
      it "should return user roles, not including system roles" do
        Role.delete_all
        user_role = Factory(:role, :user_role => true, :name => "user role")
        system_role = Factory(:role, :user_role => false, :name => "system role")
        Role.user_roles.should == [user_role]
      end
    end
  end
  
  describe "validations" do
    before(:each) do
      @role = Factory.build(:role, :name => "Public")
    end
    
    it "should be valid" do
      @role.valid?.should be_true
    end
    
    it "should be invalid if a Role already exists with same name" do
      Factory(:role, :name => "Public")
      @role.valid?.should be_false
    end
  end
end
