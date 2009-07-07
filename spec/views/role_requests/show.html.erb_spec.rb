require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/role_requests/show.html.erb" do
  include RoleRequestsHelper
  before(:each) do
    assigns[:role_request] = @role_request = stub_model(RoleRequest,
      :requester_id => "value for requester_id",
      :role_id => "value for role_id",
      :approver_id => "value for approver_id"
    )
  end

  it "renders attributes in <p>" do
    render
    response.should have_text(/value\ for\ requester_id/)
    response.should have_text(/value\ for\ role_id/)
    response.should have_text(/value\ for\ approver_id/)
  end
end

