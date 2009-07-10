require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/phin_jurisdictions/edit.html.erb" do
  include PhinJurisdictionsHelper

  before(:each) do
    assigns[:phin_jurisdiction] = @phin_jurisdiction = stub_model(PhinJurisdiction,
      :new_record? => false
    )
  end

  it "renders the edit phin_jurisdiction form" do
    render

    response.should have_tag("form[action=#{phin_jurisdiction_path(@phin_jurisdiction)}][method=post]") do
    end
  end
end
