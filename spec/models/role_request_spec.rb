# == Schema Information
#
# Table name: role_requests
#
#  id              :integer(4)      not null, primary key
#  requester_id    :string(255)
#  role_id         :string(255)
#  approver_id     :string(255)
#  created_at      :datetime
#  updated_at      :datetime
#  jurisdiction_id :integer(4)
#

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe RoleRequest do
  describe "validations" do
    before(:each) do
      @role_request = Factory.build(:role_request,
        :requester => stub_model(User),
        :role => stub_model(Role),
        :approver => stub_model(User),
        :jurisdiction => stub_model(Jurisdiction)
      )
    end
  end
  
  should_make_fields_protected :approver_id
  
  describe "named scope" do
    describe "in_jurisdictions" do
      before(:each) do
        user=Factory(:user)
        role=Factory(:role)
        @j1,j2,j3 = [Factory(:jurisdiction), Factory(:jurisdiction), Factory(:jurisdiction)]
        Factory(:role_request, :requester => user, :role => role, :jurisdiction => @j1)
        Factory(:role_request, :requester => user, :role => role, :jurisdiction => j2)
        Factory(:role_request, :requester => user, :role => role, :jurisdiction => j3)
      end
      it "should only return requests from the given jurisdiction" do
        RoleRequest.in_jurisdictions(@j1).size.should == 1
      end
    end
  end
  
  describe "creating a role request" do
    context "when the requester is an admin of the requested jurisdiction" do
      before(:each) do
        @user = Factory(:user)
        @jurisdiction = Factory(:jurisdiction)
        @admin_role = Role.admin
        @role_membership = Factory(:role_membership, :role => @admin_role, :jurisdiction => @jurisdiction, :user => @user)
        @role = Factory(:role, :name => "Foobar")
        @request = Factory.build(:role_request, :requester => @user, :jurisdiction => @jurisdiction, :role => @role, :approver => nil)
      end

      it "should approve the request" do
        @request.save!
        @request.approved?.should be_true
      end
      
      it "should set the approver to the requesting admin" do
        @request.save!
        @request.approver.should == @user
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
