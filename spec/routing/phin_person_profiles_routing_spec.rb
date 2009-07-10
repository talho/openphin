require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe PhinPersonProfilesController do
  describe "route generation" do
    it "maps #index" do
      route_for(:controller => "phin_person_profiles", :action => "index").should == "/phin_person_profiles"
    end
  
    it "maps #new" do
      route_for(:controller => "phin_person_profiles", :action => "new").should == "/phin_person_profiles/new"
    end
  
    it "maps #show" do
      route_for(:controller => "phin_person_profiles", :action => "show", :id => "1").should == "/phin_person_profiles/1"
    end
  
    it "maps #edit" do
      route_for(:controller => "phin_person_profiles", :action => "edit", :id => "1").should == "/phin_person_profiles/1/edit"
    end

  it "maps #create" do
    route_for(:controller => "phin_person_profiles", :action => "create").should == {:path => "/phin_person_profiles", :method => :post}
  end

  it "maps #update" do
    route_for(:controller => "phin_person_profiles", :action => "update", :id => "1").should == {:path =>"/phin_person_profiles/1", :method => :put}
  end
  
    it "maps #destroy" do
      route_for(:controller => "phin_person_profiles", :action => "destroy", :id => "1").should == {:path =>"/phin_person_profiles/1", :method => :delete}
    end
  end

  describe "route recognition" do
    it "generates params for #index" do
      params_from(:get, "/phin_person_profiles").should == {:controller => "phin_person_profiles", :action => "index"}
    end
  
    it "generates params for #new" do
      params_from(:get, "/phin_person_profiles/new").should == {:controller => "phin_person_profiles", :action => "new"}
    end
  
    it "generates params for #create" do
      params_from(:post, "/phin_person_profiles").should == {:controller => "phin_person_profiles", :action => "create"}
    end
  
    it "generates params for #show" do
      params_from(:get, "/phin_person_profiles/1").should == {:controller => "phin_person_profiles", :action => "show", :id => "1"}
    end
  
    it "generates params for #edit" do
      params_from(:get, "/phin_person_profiles/1/edit").should == {:controller => "phin_person_profiles", :action => "edit", :id => "1"}
    end
  
    it "generates params for #update" do
      params_from(:put, "/phin_person_profiles/1").should == {:controller => "phin_person_profiles", :action => "update", :id => "1"}
    end
  
    it "generates params for #destroy" do
      params_from(:delete, "/phin_person_profiles/1").should == {:controller => "phin_person_profiles", :action => "destroy", :id => "1"}
    end
  end
end
