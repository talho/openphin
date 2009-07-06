require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/phin_people/show.html.erb" do
  include PhinPeopleHelper
  before(:each) do
    assigns[:phin_person] = @phin_person = stub_model(PhinPerson, :id => "externalUID=1")
  end

  it "renders attributes in <p>" do
    render
  end
end

