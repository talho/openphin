require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/phin_roles/index.html.erb" do
  include PhinRolesHelper
  
  before(:each) do
    assigns[:phin_roles] = [
      stub_model(PhinRole,
        :name => "value for name",
        :approval_required => false
      ),
      stub_model(PhinRole,
        :name => "value for name",
        :approval_required => false
      )
    ]
  end

  it "renders a list of phin_roles" do
    render
    response.should have_tag("tr>td", "value for name".to_s, 2)
    response.should have_tag("tr>td", false.to_s, 2)
  end
end

