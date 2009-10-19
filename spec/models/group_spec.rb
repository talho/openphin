# == Schema Information
#
# Table name: groups
#
#  id                    :integer(4)      not null, primary key
#  name                  :string(255)
#  owner_id              :integer(4)
#  scope                 :string(255)
#  created_at            :datetime
#  updated_at            :datetime
#  owner_jurisdiction_id :integer(4)
#

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Group do

	describe "validations" do
		before(:each) do
      @jurisdiction = Factory(:jurisdiction)
      Factory(:jurisdiction).move_to_child_of(@jurisdiction)
			@group=Factory(:group, :users => [Factory(:user)])
		end

		it "be valid" do
			@group.should be_valid
		end
	end

  #TODO when i have time, convert this block to a cucumber table
	describe "create_snapshot" do
    before(:each) do
      @j1=Factory(:jurisdiction)
      @r1=Factory(:role)
      @u1 = Factory(:user)
        Factory(:role_membership, :jurisdiction => @j1, :role => @r1, :user => @u1)
      @u2 = Factory(:user)
        Factory(:role_membership, :jurisdiction => @j1, :role => Factory(:role), :user => @u2)
      @u3 = Factory(:user)
        Factory(:role_membership, :jurisdiction => Factory(:jurisdiction), :role => @r1, :user => @u3)

    end
		it "should return a GroupSnapshot model" do
      Factory(:group, :users => [Factory(:user)]).create_snapshot.class.should == GroupSnapshot
		end
		it "should include users with both jurisdiction and roles specified" do
      snap=Factory(:group, :jurisdictions => [@j1], :roles => [@r1]).create_snapshot
      snap.users.should include(@u1)
      snap.users.should_not include(@u2)
    end
		it "should include all users from jurisdiction when only jurisdiction is specified" do
      snap=Factory(:group, :jurisdictions => [@j1]).create_snapshot
      snap.users.should include(@u1)
      snap.users.should include(@u2)
      snap.users.should_not include(@u3)
    end

		it "should not include users in other jurisdictions when jurisdiction is specified" do
      snap=Factory(:group, :jurisdictions => [@j1]).create_snapshot
      snap.users.should include(@u1)
      snap.users.should include(@u2)
      snap.users.should_not include(@u3)
    end
		it "should include all users with role when only role is specified"  do
      snap=Factory(:group, :roles => [@r1]).create_snapshot
      snap.users.should include(@u1)
      snap.users.should_not include(@u2)
      snap.users.should include(@u3)
    end
		it "should include users specified in the group definition" do
      snap=Factory(:group, :users => [@u1, @u2, @u3]).create_snapshot
      snap.users.should include(@u1)
      snap.users.should include(@u2)
      snap.users.should include(@u3)
    end
	end
end
