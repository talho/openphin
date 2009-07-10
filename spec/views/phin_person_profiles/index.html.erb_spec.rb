require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/phin_person_profiles/index.html.erb" do
  include PhinPersonProfilesHelper
  
  before(:each) do
    assigns[:phin_person_profiles] = [
      stub_model(PhinPersonProfile,
        :photo => ,
        :public => false,
        :credentials => "value for credentials",
        :employer => "value for employer",
        :experience => "value for experience",
        :bio => "value for bio"
      ),
      stub_model(PhinPersonProfile,
        :photo => ,
        :public => false,
        :credentials => "value for credentials",
        :employer => "value for employer",
        :experience => "value for experience",
        :bio => "value for bio"
      )
    ]
  end

  it "renders a list of phin_person_profiles" do
    render
    response.should have_tag("tr>td", .to_s, 2)
    response.should have_tag("tr>td", false.to_s, 2)
    response.should have_tag("tr>td", "value for credentials".to_s, 2)
    response.should have_tag("tr>td", "value for employer".to_s, 2)
    response.should have_tag("tr>td", "value for experience".to_s, 2)
    response.should have_tag("tr>td", "value for bio".to_s, 2)
  end
end

