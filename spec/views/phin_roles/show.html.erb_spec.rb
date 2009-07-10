require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/phin_roles/show.html.erb" do
  include PhinRolesHelper
  before(:each) do
    assigns[:phin_role] = @phin_role = stub_model(PhinRole,
      :name => "value for name",
      :approval_required => false
    )
  end

  it "renders attributes in <p>" do
    render
    response.should have_text(/value\ for\ name/)
    response.should have_text(/false/)
  end
end

