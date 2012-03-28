# == Schema Information
#
# Table name: role_requests
#
#  id              :integer(4)      not null, primary key
#  requester_id    :integer(4)
#  role_id         :integer(4)
#  approver_id     :integer(4)
#  created_at      :datetime
#  updated_at      :datetime
#  jurisdiction_id :integer(4)
#  user_id         :integer(4)
#

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe RoleRequest do
  describe "validations" do
    before(:each) do
      @role_request = Factory.build(:role_request,
        :requester => stub_model(User),
        :user => stub_model(User),
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
        @j1,j2,j3 = [FactoryGirl.create(:jurisdiction), FactoryGirl.create(:jurisdiction), FactoryGirl.create(:jurisdiction)]
        j2.move_to_child_of(@j1)
        j3.move_to_child_of(j2)
        user=FactoryGirl.create(:user)
        role=FactoryGirl.create(:role)
        FactoryGirl.create(:role_request, :user => user, :requester => user, :role => role, :jurisdiction => @j1)
        FactoryGirl.create(:role_request, :user => user, :requester => user, :role => role, :jurisdiction => j2)
        FactoryGirl.create(:role_request, :user => user, :requester => user, :role => role, :jurisdiction => j3)
      end
      it "should only return requests from the given jurisdiction" do
        RoleRequest.in_jurisdictions(@j1).size.should == 1
      end
    end
  end
  
  describe "creating a role request" do
    context "when the requester is an admin of the requested jurisdiction" do
      before(:each) do
        @jurisdiction = FactoryGirl.create(:jurisdiction)
        @admin = FactoryGirl.create(:user)
        @user = FactoryGirl.create(:user)
        @admin_role = Role.admin
        @role_membership = FactoryGirl.create(:role_membership, :role => @admin_role, :jurisdiction => @jurisdiction, :user => @admin)
        @role = FactoryGirl.create(:role, :name => "Foobar", :approval_required => true)
        @request = Factory.build(:role_request, :user => @user, :requester => @admin, :jurisdiction => @jurisdiction, :role => @role, :approver => nil)
        @admin.reload
        @user.reload
      end

      it "should approve the request" do
        @request.save!
        @request.approved?.should be_true
      end
      
      it "should set the approver to the requesting admin" do
        @request.save!
        @request.approver.should == @admin
      end
    end
    
  end
  
  describe "#approve!" do
    before(:each) do
      @jurisdiction = FactoryGirl.create(:jurisdiction)
      FactoryGirl.create(:jurisdiction).move_to_child_of(@jurisdiction)
      @approver=FactoryGirl.create(:user)
      @approver.role_memberships.create(:jurisdiction => @jurisdiction, :role => Role.admin)
    end
    
    it "should set approver to the passed-in user" do
      role = FactoryGirl.create(:role, :approval_required => true)
      request = FactoryGirl.create(:role_request, :role => role, :requester => @approver, :user => @approver)
      request.approve!(@approver)
      request.approver.should == @approver
    end 

    it "should create a role membership for the requester" do
      user = FactoryGirl.create(:user)
      request = FactoryGirl.create(:role_request, :user => user, :requester => user)
      request.approve!(@approver)
      request.role_membership.should_not be_nil
    end
    
    describe "creating the role membership" do
      it "should assign the requester to the role membership" do
        user = FactoryGirl.create(:user)
        request = FactoryGirl.create(:role_request, :user => user, :requester => user)
        request.approve!(@approver)
        request.role_membership.user.should == user
      end
    
      it "should assign the request's jurisdiction to the role membership" do
        request = FactoryGirl.create(:role_request, :jurisdiction => @jurisdiction, :user => @approver, :requester => @approver)
        request.approve!(@approver)
        request.role_membership.jurisdiction.should == @jurisdiction
      end
    
      it "should assign the request's role to the role membership" do
        role = FactoryGirl.create(:role)
        request = FactoryGirl.create(:role_request, :role => role, :jurisdiction => @jurisdiction, :user => @approver, :requester => @approver)
        request.approve!(@approver)
        request.role_membership.role.should == role
      end

      it "should only create a single role membership" do
        user=FactoryGirl.create(:user)
        role=FactoryGirl.create(:role, :approval_required => true)
        request=FactoryGirl.create(:role_request, :user => user, :requester => user, :jurisdiction => @jurisdiction, :role => role)
        user.reload
        request.approve!(@approver)
        user.reload
        user.role_memberships.size.should == 2
      end

      context "as an admin" do
        it "should only create a single role membership" do
          jur=FactoryGirl.create(:jurisdiction)
          jur.move_to_child_of(@jurisdiction)
          user=FactoryGirl.create(:user)
          user.role_memberships.create(:role => Role.admin, :jurisdiction => jur)
        
          role=FactoryGirl.create(:role, :approval_required => true)
          request=FactoryGirl.create(:role_request, :user => user, :requester => user, :jurisdiction => jur, :role => role)
          request.approve!(@approver)
          user.role_memberships.size.should == 2
        end
      end
    end
  end
end
