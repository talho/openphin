require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/phin_people/index.html.erb" do
  include PhinPeopleHelper
  
  before(:each) do
    assigns[:phin_people] = [
      stub_model(PhinPerson, :id => "externalUID=1"),
      stub_model(PhinPerson, :id => "externalUID=2")
    ]
  end

  it "renders a list of phin_people" do
    render
  end
end

