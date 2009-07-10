require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/phin_jurisdictions/new.html.erb" do
  include PhinJurisdictionsHelper

  before(:each) do
    assigns[:phin_jurisdiction] = stub_model(PhinJurisdiction,
      :new_record? => true
    )
  end

  it "renders new phin_jurisdiction form" do
    render

    response.should have_tag("form[action=?][method=post]", phin_jurisdictions_path) do
    end
  end
end
