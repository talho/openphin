require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/role_requests/new.html.erb" do
  include RoleRequestsHelper
  
  before(:each) do
    assigns[:role_request] = stub_model(RoleRequest,
      :new_record? => true,
      :requester_id => "value for requester_id",
      :role_id => "value for role_id",
      :approver_id => "value for approver_id"
    )
  end

  it "renders new role_request form" do
    render
    
    response.should have_tag("form[action=?][method=post]", role_requests_path) do
      with_tag("input#role_request_requester_id[name=?]", "role_request[requester_id]")
      with_tag("input#role_request_role_id[name=?]", "role_request[role_id]")
      with_tag("input#role_request_approver_id[name=?]", "role_request[approver_id]")
    end
  end
end


