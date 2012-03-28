# == Schema Information
#
# Table name: audiences
#
#  id                    :integer(4)      not null, primary key
#  name                  :string(255)
#  owner_id              :integer(4)
#  scope                 :string(255)
#  created_at            :datetime
#  updated_at            :datetime
#  owner_jurisdiction_id :integer(4)
#  type                  :string(255)
#

require File.dirname(__FILE__) + '/../spec_helper'

describe Audience do
  describe "foreign users" do
    it "should detect and return users with foreign jurisdictions named in the alert" do
      j1 = FactoryGirl.create(:jurisdiction, :foreign => true)
      j2 = FactoryGirl.create(:jurisdiction)
      u1 = FactoryGirl.create(:user)
      role = FactoryGirl.create(:role)
      FactoryGirl.create(:role_membership, :user => u1, :role => role, :jurisdiction => j1)
      u2 = FactoryGirl.create(:user)
      FactoryGirl.create(:role_membership, :user => u2, :role => role, :jurisdiction => j2)
      u3 = FactoryGirl.create(:user)
      FactoryGirl.create(:role_membership, :user => u3, :role => role, :jurisdiction => j1)
      FactoryGirl.create(:role_membership, :user => u3, :role => role, :jurisdiction => j2)

      audience = FactoryGirl.create(:audience, :users => [u1,u2,u3])
      audience.foreign_users.should include(u1)
      audience.foreign_users.should_not include(u2)
      audience.foreign_users.should include(u3)
    end
  end
end
