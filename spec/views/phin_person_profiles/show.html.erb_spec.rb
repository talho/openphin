require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/phin_person_profiles/show.html.erb" do
  include PhinPersonProfilesHelper
  before(:each) do
    assigns[:phin_person_profile] = @phin_person_profile = stub_model(PhinPersonProfile,
      # :photo => ,
      :public => false,
      :credentials => "value for credentials",
      :employer => "value for employer",
      :experience => "value for experience",
      :bio => "value for bio"
    )
  end

  it "renders attributes in <p>" do
    render
    response.should have_text(//)
    response.should have_text(/false/)
    response.should have_text(/value\ for\ credentials/)
    response.should have_text(/value\ for\ employer/)
    response.should have_text(/value\ for\ experience/)
    response.should have_text(/value\ for\ bio/)
  end
end

