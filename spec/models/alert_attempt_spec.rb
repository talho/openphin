require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')


describe "AlertAttempt" do

	describe "named scope for_jurisdiction" do
		before(:each) do
			@alert=Factory(:alert)
			@j1=Factory(:jurisdiction)
			@j2=Factory(:jurisdiction)
			@j3=Factory(:jurisdiction)
			role=Factory(:role)
			u1=Factory(:user)
			u2=Factory(:user)
			u3=Factory(:user)
			u4=Factory(:user)
			u1.role_memberships.create!(:role => role, :jurisdiction => @j1)
			u2.role_memberships.create!(:role => role, :jurisdiction => @j1)
			u2.role_memberships.create!(:role => role, :jurisdiction => @j2)
			u3.role_memberships.create!(:role => role, :jurisdiction => @j3)
			u4.role_memberships.create!(:role => Factory(:role), :jurisdiction => @j2)
			@alert.jurisdictions<< @j1
			@alert.jurisdictions<< @j2
			@alert.roles<< role
			@alert.alert_attempts.create!(:user => u1)
			@alert.alert_attempts.create!(:user => u2, :acknowledged_at => Time.zone.now)
			@alert.reload
		end
		it "should return correct number of attempts for given jurisdiction" do
			@alert.acknowledged_percent_for_jurisdiction(@j1).round.should == 50.0
			@alert.acknowledged_percent_for_jurisdiction(@j2).round.should == 100.0
		end
	end
end
