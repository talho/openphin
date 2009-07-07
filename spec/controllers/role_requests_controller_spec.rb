require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe RoleRequestsController do

  def mock_role_request(stubs={})
    @mock_role_request ||= mock_model(RoleRequest, stubs)
  end
  
  describe "GET index" do
    it "assigns all role_requests as @role_requests" do
      RoleRequest.stub!(:find).with(:all).and_return([mock_role_request])
      get :index
      assigns[:role_requests].should == [mock_role_request]
    end
  end

  describe "GET show" do
    it "assigns the requested role_request as @role_request" do
      RoleRequest.stub!(:find).with("37").and_return(mock_role_request)
      get :show, :id => "37"
      assigns[:role_request].should equal(mock_role_request)
    end
  end

  describe "GET new" do
    it "assigns a new role_request as @role_request" do
      RoleRequest.stub!(:new).and_return(mock_role_request)
      get :new
      assigns[:role_request].should equal(mock_role_request)
    end
  end

  describe "GET edit" do
    it "assigns the requested role_request as @role_request" do
      RoleRequest.stub!(:find).with("37").and_return(mock_role_request)
      get :edit, :id => "37"
      assigns[:role_request].should equal(mock_role_request)
    end
  end

  describe "POST create" do
    
    describe "with valid params" do
      it "assigns a newly created role_request as @role_request" do
        RoleRequest.stub!(:new).with({'these' => 'params'}).and_return(mock_role_request(:save => true))
        post :create, :role_request => {:these => 'params'}
        assigns[:role_request].should equal(mock_role_request)
      end

      it "redirects to the created role_request" do
        RoleRequest.stub!(:new).and_return(mock_role_request(:save => true))
        post :create, :role_request => {}
        response.should redirect_to(role_request_url(mock_role_request))
      end
    end
    
    describe "with invalid params" do
      it "assigns a newly created but unsaved role_request as @role_request" do
        RoleRequest.stub!(:new).with({'these' => 'params'}).and_return(mock_role_request(:save => false))
        post :create, :role_request => {:these => 'params'}
        assigns[:role_request].should equal(mock_role_request)
      end

      it "re-renders the 'new' template" do
        RoleRequest.stub!(:new).and_return(mock_role_request(:save => false))
        post :create, :role_request => {}
        response.should render_template('new')
      end
    end
    
  end

  describe "PUT update" do
    
    describe "with valid params" do
      it "updates the requested role_request" do
        RoleRequest.should_receive(:find).with("37").and_return(mock_role_request)
        mock_role_request.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => "37", :role_request => {:these => 'params'}
      end

      it "assigns the requested role_request as @role_request" do
        RoleRequest.stub!(:find).and_return(mock_role_request(:update_attributes => true))
        put :update, :id => "1"
        assigns[:role_request].should equal(mock_role_request)
      end

      it "redirects to the role_request" do
        RoleRequest.stub!(:find).and_return(mock_role_request(:update_attributes => true))
        put :update, :id => "1"
        response.should redirect_to(role_request_url(mock_role_request))
      end
    end
    
    describe "with invalid params" do
      it "updates the requested role_request" do
        RoleRequest.should_receive(:find).with("37").and_return(mock_role_request)
        mock_role_request.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => "37", :role_request => {:these => 'params'}
      end

      it "assigns the role_request as @role_request" do
        RoleRequest.stub!(:find).and_return(mock_role_request(:update_attributes => false))
        put :update, :id => "1"
        assigns[:role_request].should equal(mock_role_request)
      end

      it "re-renders the 'edit' template" do
        RoleRequest.stub!(:find).and_return(mock_role_request(:update_attributes => false))
        put :update, :id => "1"
        response.should render_template('edit')
      end
    end
    
  end

  describe "DELETE destroy" do
    it "destroys the requested role_request" do
      RoleRequest.should_receive(:find).with("37").and_return(mock_role_request)
      mock_role_request.should_receive(:destroy)
      delete :destroy, :id => "37"
    end
  
    it "redirects to the role_requests list" do
      RoleRequest.stub!(:find).and_return(mock_role_request(:destroy => true))
      delete :destroy, :id => "1"
      response.should redirect_to(role_requests_url)
    end
  end

end
