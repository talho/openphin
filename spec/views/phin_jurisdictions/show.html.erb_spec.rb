require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/phin_jurisdictions/show.html.erb" do
  include PhinJurisdictionsHelper
  before(:each) do
    assigns[:phin_jurisdiction] = @phin_jurisdiction = stub_model(PhinJurisdiction)
  end

  it "renders attributes in <p>" do
    render
  end
end
