require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/role_requests/index.html.erb" do
  include RoleRequestsHelper
  
  before(:each) do
    assigns[:role_requests] = [
      stub_model(RoleRequest,
        :requester_id => "value for requester_id",
        :role_id => "value for role_id",
        :approver_id => "value for approver_id"
      ),
      stub_model(RoleRequest,
        :requester_id => "value for requester_id",
        :role_id => "value for role_id",
        :approver_id => "value for approver_id"
      )
    ]
  end

  it "renders a list of role_requests" do
    render
    response.should have_tag("tr>td", "value for requester_id".to_s, 2)
    response.should have_tag("tr>td", "value for role_id".to_s, 2)
    response.should have_tag("tr>td", "value for approver_id".to_s, 2)
  end
end

