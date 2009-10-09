require File.dirname(__FILE__) + '/../spec_helper'

describe SearchesController do
  before(:each) do
    @jurisdiction1 =Factory(:jurisdiction)
    @jurisdiction2 = Factory(:jurisdiction)
    @jurisdiction2.move_to_child_of(@jurisdiction1)
    user = Factory(:user)
    Factory(:role_membership, :user => user, :role => Factory(:role, :approval_required => true), :jurisdiction => @jurisdiction2)
    login_as(user)
  end
  
  describe 'show' do
    before do
      @user1 = Factory(:user, :last_name => 'Smith')
      @user2 = Factory(:user, :last_name => 'Smithers')
    end
    
    def do_action
      get :show, :tag => 'smith', :format => 'json'
    end
      
    it 'should search the users' do
      User.should_receive(:search).and_return([])
      do_action
    end
    
    it 'should return users as a json object' do
      User.stub!(:search).and_return([@user1, @user2])
      do_action
      response.body.should include_text("\"caption\":\"#{@user1.name}\"")
      response.body.should include_text("\"value\":#{@user1.id}")
    end
  end
end
