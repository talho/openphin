require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe PhinJurisdictionsController do

  def mock_phin_jurisdiction(stubs={})
    @mock_phin_jurisdiction ||= mock_model(PhinJurisdiction, stubs)
  end

  describe "GET index" do
    it "assigns all phin_jurisdictions as @phin_jurisdictions" do
      PhinJurisdiction.stub!(:find).with(:all).and_return([mock_phin_jurisdiction])
      get :index
      assigns[:phin_jurisdictions].should == [mock_phin_jurisdiction]
    end
  end

  describe "GET show" do
    it "assigns the requested phin_jurisdiction as @phin_jurisdiction" do
      PhinJurisdiction.stub!(:find).with("37").and_return(mock_phin_jurisdiction)
      get :show, :id => "37"
      assigns[:phin_jurisdiction].should equal(mock_phin_jurisdiction)
    end
  end

  describe "GET new" do
    it "assigns a new phin_jurisdiction as @phin_jurisdiction" do
      PhinJurisdiction.stub!(:new).and_return(mock_phin_jurisdiction)
      get :new
      assigns[:phin_jurisdiction].should equal(mock_phin_jurisdiction)
    end
  end

  describe "GET edit" do
    it "assigns the requested phin_jurisdiction as @phin_jurisdiction" do
      PhinJurisdiction.stub!(:find).with("37").and_return(mock_phin_jurisdiction)
      get :edit, :id => "37"
      assigns[:phin_jurisdiction].should equal(mock_phin_jurisdiction)
    end
  end

  describe "POST create" do

    describe "with valid params" do
      it "assigns a newly created phin_jurisdiction as @phin_jurisdiction" do
        PhinJurisdiction.stub!(:new).with({'these' => 'params'}).and_return(mock_phin_jurisdiction(:save => true))
        post :create, :phin_jurisdiction => {:these => 'params'}
        assigns[:phin_jurisdiction].should equal(mock_phin_jurisdiction)
      end

      it "redirects to the created phin_jurisdiction" do
        PhinJurisdiction.stub!(:new).and_return(mock_phin_jurisdiction(:save => true))
        post :create, :phin_jurisdiction => {}
        response.should redirect_to(phin_jurisdiction_url(mock_phin_jurisdiction))
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved phin_jurisdiction as @phin_jurisdiction" do
        PhinJurisdiction.stub!(:new).with({'these' => 'params'}).and_return(mock_phin_jurisdiction(:save => false))
        post :create, :phin_jurisdiction => {:these => 'params'}
        assigns[:phin_jurisdiction].should equal(mock_phin_jurisdiction)
      end

      it "re-renders the 'new' template" do
        PhinJurisdiction.stub!(:new).and_return(mock_phin_jurisdiction(:save => false))
        post :create, :phin_jurisdiction => {}
        response.should render_template('new')
      end
    end

  end

  describe "PUT update" do

    describe "with valid params" do
      it "updates the requested phin_jurisdiction" do
        PhinJurisdiction.should_receive(:find).with("37").and_return(mock_phin_jurisdiction)
        mock_phin_jurisdiction.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => "37", :phin_jurisdiction => {:these => 'params'}
      end

      it "assigns the requested phin_jurisdiction as @phin_jurisdiction" do
        PhinJurisdiction.stub!(:find).and_return(mock_phin_jurisdiction(:update_attributes => true))
        put :update, :id => "1"
        assigns[:phin_jurisdiction].should equal(mock_phin_jurisdiction)
      end

      it "redirects to the phin_jurisdiction" do
        PhinJurisdiction.stub!(:find).and_return(mock_phin_jurisdiction(:update_attributes => true))
        put :update, :id => "1"
        response.should redirect_to(phin_jurisdiction_url(mock_phin_jurisdiction))
      end
    end

    describe "with invalid params" do
      it "updates the requested phin_jurisdiction" do
        PhinJurisdiction.should_receive(:find).with("37").and_return(mock_phin_jurisdiction)
        mock_phin_jurisdiction.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => "37", :phin_jurisdiction => {:these => 'params'}
      end

      it "assigns the phin_jurisdiction as @phin_jurisdiction" do
        PhinJurisdiction.stub!(:find).and_return(mock_phin_jurisdiction(:update_attributes => false))
        put :update, :id => "1"
        assigns[:phin_jurisdiction].should equal(mock_phin_jurisdiction)
      end

      it "re-renders the 'edit' template" do
        PhinJurisdiction.stub!(:find).and_return(mock_phin_jurisdiction(:update_attributes => false))
        put :update, :id => "1"
        response.should render_template('edit')
      end
    end

  end

  describe "DELETE destroy" do
    it "destroys the requested phin_jurisdiction" do
      PhinJurisdiction.should_receive(:find).with("37").and_return(mock_phin_jurisdiction)
      mock_phin_jurisdiction.should_receive(:destroy)
      delete :destroy, :id => "37"
    end

    it "redirects to the phin_jurisdictions list" do
      PhinJurisdiction.stub!(:find).and_return(mock_phin_jurisdiction(:destroy => true))
      delete :destroy, :id => "1"
      response.should redirect_to(phin_jurisdictions_url)
    end
  end

end
