require File.dirname(__FILE__) + '/../spec_helper'

describe Audience do
  describe "foreign users" do
    it "should detect and return users with foreign jurisdictions named in the alert" do
      j1 = Factory(:jurisdiction, :foreign => true)
      j2 = Factory(:jurisdiction)
      u1 = Factory(:user)
      role = Factory(:role)
      Factory(:role_membership, :user => u1, :role => role, :jurisdiction => j1)
      u2 = Factory(:user)
      Factory(:role_membership, :user => u2, :role => role, :jurisdiction => j2)
      u3 = Factory(:user)
      Factory(:role_membership, :user => u3, :role => role, :jurisdiction => j1)
      Factory(:role_membership, :user => u3, :role => role, :jurisdiction => j2)

      audience = Factory(:audience, :users => [u1,u2,u3])
      audience.foreign_users.should include(u1)
      audience.foreign_users.should_not include(u2)
      audience.foreign_users.should include(u3)
    end
  end
end
