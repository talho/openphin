# == Schema Information
#
# Table name: alert_attempts
#
#  id                                :integer(4)      not null, primary key
#  alert_id                          :integer(4)
#  user_id                           :integer(4)
#  requested_at                      :datetime
#  acknowledged_at                   :datetime
#  created_at                        :datetime
#  updated_at                        :datetime
#  organization_id                   :integer(4)
#  token                             :string(255)
#  jurisdiction_id                   :integer(4)
#  acknowledged_alert_device_type_id :integer(4)
#

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
			audience = @alert.audiences.build
			audience.jurisdictions << @j1
			audience.jurisdictions << @j2
			audience.roles << role
			@alert.alert_attempts.create!(:user => u1)
			@alert.alert_attempts.create!(:user => u2, :acknowledged_at => Time.zone.now)
			@alert.reload
		end
		it "should return correct number of attempts for given jurisdiction" do
			@alert.acknowledged_percent_for_jurisdiction(@j1).round.should == 50.0
			@alert.acknowledged_percent_for_jurisdiction(@j2).round.should == 100.0
		end
  end

  context "creating an alert attempt" do
    it "should assign a random token" do
      alert_attempt = Factory.build(:alert_attempt, :token => nil)
      alert_attempt.save!
      alert_attempt.token.should_not be_nil
    end
  end
  
  context '#acknowledged?' do
    it 'should return true when acknowledged_at is not blank' do
      alert_attempt = AlertAttempt.new :acknowledged_at => Time.now
      alert_attempt.acknowledged?.should be_true
    end
    
    it 'should return false when acknowledged_at is blank' do
      alert_attempt = AlertAttempt.new :acknowledged_at => nil
      alert_attempt.acknowledged?.should be_false
    end
  end
end
