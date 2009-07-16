# == Schema Information
#
# Table name: role_requests
#
#  id              :integer         not null, primary key
#  requester_id    :string(255)
#  role_id         :string(255)
#  approver_id     :string(255)
#  created_at      :datetime
#  updated_at      :datetime
#  jurisdiction_id :integer
#

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe RoleRequest do
  before(:each) do
    @valid_attributes = {
      :requester => mock_model(User),
      :role => mock_model(Role),
      :approver => mock_model(User)
    }
  end

  it "should create a new instance given valid attributes" do
    RoleRequest.create!(@valid_attributes)
  end

  describe "named scope" do
    describe "in_jurisdictions" do
      before(:each) do
        user=Factory(:user)
        role=Factory(:role)
        j1,j2,j3 = [Factory(:jurisdiction), Factory(:jurisdiction), Factory(:jurisdiction)]
        Factory(:role_request, :requester => user, :role => role, :jurisdiction => j1)
        Factory(:role_request, :requester => user, :role => role, :jurisdiction => j2)
        Factory(:role_request, :requester => user, :role => role, :jurisdiction => j3)
      end
      it "should only return requests from the given jurisdiction" do
        RoleRequest.in_jurisdictions(Jurisdiction.first).size.should == 1
      end
    end
  end
  
  describe "#approve!" do
    before(:each) do
      @approver=Factory(:user)
    end
    
    it "should set approver to the passed-in user" do
      request = Factory(:role_request)
      request.approve!(@approver)
      request.approver.should == @approver
    end 

    it "should create a role membership for the requester" do
      user = Factory(:user)
      request = Factory(:role_request)
      request.approve!(@approver)
      request.role_membership.should_not be_nil
    end
    
    describe "creating the role membership" do
      it "should assign the requester to the role membership" do
        user = Factory(:user)
        request = Factory(:role_request, :requester => user)
        request.approve!(@approver)
        request.role_membership.user.should == user
      end
    
      it "should assign the request's jurisdiction to the role membership" do
        jurisdiction = Factory(:jurisdiction)
        request = Factory(:role_request, :jurisdiction => jurisdiction)
        request.approve!(@approver)
        request.role_membership.jurisdiction.should == jurisdiction
      end
    
      it "should assign the request's role to the role membership" do
        role = Factory(:role)
        request = Factory(:role_request, :role => role)
        request.approve!(@approver)
        request.role_membership.role.should == role
      end 
    end
  end
end
