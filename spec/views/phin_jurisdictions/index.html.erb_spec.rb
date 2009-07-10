require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/phin_jurisdictions/index.html.erb" do
  include PhinJurisdictionsHelper

  before(:each) do
    assigns[:phin_jurisdictions] = [
      stub_model(PhinJurisdiction),
      stub_model(PhinJurisdiction)
    ]
  end

  it "renders a list of phin_jurisdictions" do
    render
  end
end
