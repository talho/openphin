require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/role_requests/edit.html.erb" do
  include RoleRequestsHelper
  
  before(:each) do
    assigns[:role_request] = @role_request = stub_model(RoleRequest,
      :new_record? => false,
      :requester_id => "value for requester_id",
      :role_id => "value for role_id",
      :approver_id => "value for approver_id"
    )
  end

  it "renders the edit role_request form" do
    render
    
    response.should have_tag("form[action=#{role_request_path(@role_request)}][method=post]") do
      with_tag('input#role_request_requester_id[name=?]', "role_request[requester_id]")
      with_tag('input#role_request_role_id[name=?]', "role_request[role_id]")
      with_tag('input#role_request_approver_id[name=?]', "role_request[approver_id]")
    end
  end
end


