require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe PhinRolesController do

  def mock_phin_role(stubs={})
    @mock_phin_role ||= mock_model(PhinRole, stubs)
  end
  
  describe "GET index" do
    it "assigns all phin_roles as @phin_roles" do
      PhinRole.stub!(:find).with(:all).and_return([mock_phin_role])
      get :index
      assigns[:phin_roles].should == [mock_phin_role]
    end
  end

  describe "GET show" do
    it "assigns the requested phin_role as @phin_role" do
      PhinRole.stub!(:find).with("37").and_return(mock_phin_role)
      get :show, :id => "37"
      assigns[:phin_role].should equal(mock_phin_role)
    end
  end

  describe "GET new" do
    it "assigns a new phin_role as @phin_role" do
      PhinRole.stub!(:new).and_return(mock_phin_role)
      get :new
      assigns[:phin_role].should equal(mock_phin_role)
    end
  end

  describe "GET edit" do
    it "assigns the requested phin_role as @phin_role" do
      PhinRole.stub!(:find).with("37").and_return(mock_phin_role)
      get :edit, :id => "37"
      assigns[:phin_role].should equal(mock_phin_role)
    end
  end

  describe "POST create" do
    
    describe "with valid params" do
      it "assigns a newly created phin_role as @phin_role" do
        PhinRole.stub!(:new).with({'these' => 'params'}).and_return(mock_phin_role(:save => true))
        post :create, :phin_role => {:these => 'params'}
        assigns[:phin_role].should equal(mock_phin_role)
      end

      it "redirects to the created phin_role" do
        PhinRole.stub!(:new).and_return(mock_phin_role(:save => true))
        post :create, :phin_role => {}
        response.should redirect_to(phin_role_url(mock_phin_role))
      end
    end
    
    describe "with invalid params" do
      it "assigns a newly created but unsaved phin_role as @phin_role" do
        PhinRole.stub!(:new).with({'these' => 'params'}).and_return(mock_phin_role(:save => false))
        post :create, :phin_role => {:these => 'params'}
        assigns[:phin_role].should equal(mock_phin_role)
      end

      it "re-renders the 'new' template" do
        PhinRole.stub!(:new).and_return(mock_phin_role(:save => false))
        post :create, :phin_role => {}
        response.should render_template('new')
      end
    end
    
  end

  describe "PUT update" do
    
    describe "with valid params" do
      it "updates the requested phin_role" do
        PhinRole.should_receive(:find).with("37").and_return(mock_phin_role)
        mock_phin_role.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => "37", :phin_role => {:these => 'params'}
      end

      it "assigns the requested phin_role as @phin_role" do
        PhinRole.stub!(:find).and_return(mock_phin_role(:update_attributes => true))
        put :update, :id => "1"
        assigns[:phin_role].should equal(mock_phin_role)
      end

      it "redirects to the phin_role" do
        PhinRole.stub!(:find).and_return(mock_phin_role(:update_attributes => true))
        put :update, :id => "1"
        response.should redirect_to(phin_role_url(mock_phin_role))
      end
    end
    
    describe "with invalid params" do
      it "updates the requested phin_role" do
        PhinRole.should_receive(:find).with("37").and_return(mock_phin_role)
        mock_phin_role.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => "37", :phin_role => {:these => 'params'}
      end

      it "assigns the phin_role as @phin_role" do
        PhinRole.stub!(:find).and_return(mock_phin_role(:update_attributes => false))
        put :update, :id => "1"
        assigns[:phin_role].should equal(mock_phin_role)
      end

      it "re-renders the 'edit' template" do
        PhinRole.stub!(:find).and_return(mock_phin_role(:update_attributes => false))
        put :update, :id => "1"
        response.should render_template('edit')
      end
    end
    
  end

  describe "DELETE destroy" do
    it "destroys the requested phin_role" do
      PhinRole.should_receive(:find).with("37").and_return(mock_phin_role)
      mock_phin_role.should_receive(:destroy)
      delete :destroy, :id => "37"
    end
  
    it "redirects to the phin_roles list" do
      PhinRole.stub!(:find).and_return(mock_phin_role(:destroy => true))
      delete :destroy, :id => "1"
      response.should redirect_to(phin_roles_url)
    end
  end

end
