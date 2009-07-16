require File.dirname(__FILE__) + '/../spec_helper'

describe UsersController, "as a logged in user" do
  before(:each) do
    login_as_user
  end
  
  describe 'search' do
    before do
      @user1 = Factory(:user, :last_name => 'Smith')
      @user2 = Factory(:user, :last_name => 'Smithers')
    end
    
    def do_action
      get :search, :q => 'smith'
    end
      
    it 'should search the users' do
      User.should_receive(:search).with('smith').and_return([])
      do_action
    end
    
    it 'should return users as a json object' do
      do_action
      response.body.should have_text(Regexp.new(%|"caption": "#{@user1.name}"|))
      response.body.should have_text(Regexp.new(%|"value": #{@user1.id}|))
    end
  end
end
