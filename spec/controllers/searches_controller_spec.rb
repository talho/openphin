require File.dirname(__FILE__) + '/../spec_helper'

describe SearchesController do
  before(:each) do
    @jurisdiction1 =FactoryGirl.create(:jurisdiction)
    @jurisdiction2 = FactoryGirl.create(:jurisdiction)
    @jurisdiction2.move_to_child_of(@jurisdiction1)
    user = FactoryGirl.create(:user)
    FactoryGirl.create(:role_membership, :user => user, :role => FactoryGirl.create(:role, :approval_required => true), :jurisdiction => @jurisdiction2)
    login_as(user)
  end
  
  describe 'show' do
    before do
      @user1 = FactoryGirl.create(:user, :last_name => 'Smith')
      @user2 = FactoryGirl.create(:user, :last_name => 'Smithers')
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
      response.body.should include_text("\"caption\":\"#{@user1.name} #{@user1.email}\"")
      response.body.should include_text("\"value\":#{@user1.id}")
    end
  end
end
