require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe PhinPersonProfilesController do

  def mock_phin_person_profile(stubs={})
    @mock_phin_person_profile ||= mock_model(PhinPersonProfile, stubs)
  end
  
  describe "GET index" do
    it "assigns all phin_person_profiles as @phin_person_profiles" do
      PhinPersonProfile.stub!(:find).with(:all).and_return([mock_phin_person_profile])
      get :index
      assigns[:phin_person_profiles].should == [mock_phin_person_profile]
    end
  end

  describe "GET show" do
    it "assigns the requested phin_person_profile as @phin_person_profile" do
      PhinPersonProfile.stub!(:find).with("37").and_return(mock_phin_person_profile)
      get :show, :id => "37"
      assigns[:phin_person_profile].should equal(mock_phin_person_profile)
    end
  end

  describe "GET new" do
    it "assigns a new phin_person_profile as @phin_person_profile" do
      PhinPersonProfile.stub!(:new).and_return(mock_phin_person_profile)
      get :new
      assigns[:phin_person_profile].should equal(mock_phin_person_profile)
    end
  end

  describe "GET edit" do
    it "assigns the requested phin_person_profile as @phin_person_profile" do
      PhinPersonProfile.stub!(:find).with("37").and_return(mock_phin_person_profile)
      get :edit, :id => "37"
      assigns[:phin_person_profile].should equal(mock_phin_person_profile)
    end
  end

  describe "POST create" do
    
    describe "with valid params" do
      it "assigns a newly created phin_person_profile as @phin_person_profile" do
        PhinPersonProfile.stub!(:new).with({'these' => 'params'}).and_return(mock_phin_person_profile(:save => true))
        post :create, :phin_person_profile => {:these => 'params'}
        assigns[:phin_person_profile].should equal(mock_phin_person_profile)
      end

      it "redirects to the created phin_person_profile" do
        PhinPersonProfile.stub!(:new).and_return(mock_phin_person_profile(:save => true))
        post :create, :phin_person_profile => {}
        response.should redirect_to(phin_person_profile_url(mock_phin_person_profile))
      end
    end
    
    describe "with invalid params" do
      it "assigns a newly created but unsaved phin_person_profile as @phin_person_profile" do
        PhinPersonProfile.stub!(:new).with({'these' => 'params'}).and_return(mock_phin_person_profile(:save => false))
        post :create, :phin_person_profile => {:these => 'params'}
        assigns[:phin_person_profile].should equal(mock_phin_person_profile)
      end

      it "re-renders the 'new' template" do
        PhinPersonProfile.stub!(:new).and_return(mock_phin_person_profile(:save => false))
        post :create, :phin_person_profile => {}
        response.should render_template('new')
      end
    end
    
  end

  describe "PUT update" do
    
    describe "with valid params" do
      it "updates the requested phin_person_profile" do
        PhinPersonProfile.should_receive(:find).with("37").and_return(mock_phin_person_profile)
        mock_phin_person_profile.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => "37", :phin_person_profile => {:these => 'params'}
      end

      it "assigns the requested phin_person_profile as @phin_person_profile" do
        PhinPersonProfile.stub!(:find).and_return(mock_phin_person_profile(:update_attributes => true))
        put :update, :id => "1"
        assigns[:phin_person_profile].should equal(mock_phin_person_profile)
      end

      it "redirects to the phin_person_profile" do
        PhinPersonProfile.stub!(:find).and_return(mock_phin_person_profile(:update_attributes => true))
        put :update, :id => "1"
        response.should redirect_to(phin_person_profile_url(mock_phin_person_profile))
      end
    end
    
    describe "with invalid params" do
      it "updates the requested phin_person_profile" do
        PhinPersonProfile.should_receive(:find).with("37").and_return(mock_phin_person_profile)
        mock_phin_person_profile.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => "37", :phin_person_profile => {:these => 'params'}
      end

      it "assigns the phin_person_profile as @phin_person_profile" do
        PhinPersonProfile.stub!(:find).and_return(mock_phin_person_profile(:update_attributes => false))
        put :update, :id => "1"
        assigns[:phin_person_profile].should equal(mock_phin_person_profile)
      end

      it "re-renders the 'edit' template" do
        PhinPersonProfile.stub!(:find).and_return(mock_phin_person_profile(:update_attributes => false))
        put :update, :id => "1"
        response.should render_template('edit')
      end
    end
    
  end

  describe "DELETE destroy" do
    it "destroys the requested phin_person_profile" do
      PhinPersonProfile.should_receive(:find).with("37").and_return(mock_phin_person_profile)
      mock_phin_person_profile.should_receive(:destroy)
      delete :destroy, :id => "37"
    end
  
    it "redirects to the phin_person_profiles list" do
      PhinPersonProfile.stub!(:find).and_return(mock_phin_person_profile(:destroy => true))
      delete :destroy, :id => "1"
      response.should redirect_to(phin_person_profiles_url)
    end
  end

end
