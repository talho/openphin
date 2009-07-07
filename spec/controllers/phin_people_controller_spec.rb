require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe PhinPeopleController do

  def mock_phin_person(stubs={})
    @mock_phin_person ||= mock_model(PhinPerson, stubs)
  end
  
  describe "GET index" do
    it "assigns all phin_peoples as @phin_peoples" do
      PhinPerson.stub!(:find).with(:all).and_return([mock_phin_person])
      get :index
      assigns[:phin_people].should == [mock_phin_person]
    end
  end

  describe "GET show" do
    it "assigns the requested phin_person as @phin_person" do
      PhinPerson.stub!(:find).with("37").and_return(mock_phin_person)
      get :show, :id => "37"
      assigns[:phin_person].should equal(mock_phin_person)
    end
  end

  describe "GET new" do
    it "assigns a new phin_person as @phin_person" do
      PhinPerson.stub!(:new).and_return(mock_phin_person)
      get :new
      assigns[:phin_person].should equal(mock_phin_person)
    end
  end

  describe "GET edit" do
    it "assigns the requested phin_person as @phin_person" do
      PhinPerson.stub!(:find).with("37").and_return(mock_phin_person)
      get :edit, :id => "37"
      assigns[:phin_person].should equal(mock_phin_person)
    end
  end

  describe "POST create" do
    describe "with secure role request" do
      before(:all) do
        PhinRole.new(:cn => "Secure Role", :approvalRequired => true).save!
      end
      after(:all) do
        PhinRole.find("Secure Role").delete
      end
      it "should not assign the role automatically" do
        params={
            "givenName" => "John",
            "sn" => "Smith",
            "displayName" => "J S",
            "description" => "laskjdflk",
            "mail" => "js@example.org",
            "preferredLanguage" => "English",
            "title" => "tester",
            "roles[]" => "Secure Role"
        }
        post :create, :phin_person => params
        PhinPerson.find(:first, :attribute => "cn", :value => "John Smith").phin_roles.length == 0
      end
    end

    describe "with valid params" do
      it "assigns a newly created phin_person as @phin_person" do
        PhinPerson.stub!(:new).with({'these' => 'params'}).and_return(mock_phin_person(:save => true))
        post :create, :phin_person => {:these => 'params'}
        assigns[:phin_person].should equal(mock_phin_person)
      end

      it "redirects to the created phin_person" do
        PhinPerson.stub!(:new).and_return(mock_phin_person(:save => true))
        post :create, :phin_person => {}
        response.should redirect_to(phin_person_url(mock_phin_person))
      end
    end
    
    describe "with invalid params" do
      it "assigns a newly created but unsaved phin_person as @phin_person" do
        PhinPerson.stub!(:new).with({'these' => 'params'}).and_return(mock_phin_person(:save => false))
        post :create, :phin_person => {:these => 'params'}
        assigns[:phin_person].should equal(mock_phin_person)
      end

      it "re-renders the 'new' template" do
        PhinPerson.stub!(:new).and_return(mock_phin_person(:save => false))
        post :create, :phin_person => {}
        response.should render_template('new')
      end
    end
    
  end

  describe "PUT update" do
    
    describe "with valid params" do
      it "updates the requested phin_person" do
        PhinPerson.should_receive(:find).with("37").and_return(mock_phin_person)
        mock_phin_person.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => "37", :phin_person => {:these => 'params'}
      end

      it "assigns the requested phin_person as @phin_person" do
        PhinPerson.stub!(:find).and_return(mock_phin_person(:update_attributes => true))
        put :update, :id => "1"
        assigns[:phin_person].should equal(mock_phin_person)
      end

      it "redirects to the phin_person" do
        PhinPerson.stub!(:find).and_return(mock_phin_person(:update_attributes => true))
        put :update, :id => "1"
        response.should redirect_to(phin_person_url(mock_phin_person))
      end
    end
    
    describe "with invalid params" do
      it "updates the requested phin_person" do
        PhinPerson.should_receive(:find).with("37").and_return(mock_phin_person)
        mock_phin_person.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => "37", :phin_person => {:these => 'params'}
      end

      it "assigns the phin_person as @phin_person" do
        PhinPerson.stub!(:find).and_return(mock_phin_person(:update_attributes => false))
        put :update, :id => "1"
        assigns[:phin_person].should equal(mock_phin_person)
      end

      it "re-renders the 'edit' template" do
        PhinPerson.stub!(:find).and_return(mock_phin_person(:update_attributes => false))
        put :update, :id => "1"
        response.should render_template('edit')
      end
    end
    
  end

  describe "DELETE destroy" do
    it "destroys the requested phin_person" do
      PhinPerson.should_receive(:find).with("37").and_return(mock_phin_person)
      mock_phin_person.should_receive(:destroy)
      delete :destroy, :id => "37"
    end
  
    it "redirects to the phin_people list" do
      PhinPerson.stub!(:find).and_return(mock_phin_person(:destroy => true))
      delete :destroy, :id => "1"
      response.should redirect_to(phin_people_url)
    end
  end

end
