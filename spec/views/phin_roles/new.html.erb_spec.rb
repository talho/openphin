require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/phin_roles/new.html.erb" do
  include PhinRolesHelper
  
  before(:each) do
    assigns[:phin_role] = stub_model(PhinRole,
      :new_record? => true,
      :name => "value for name",
      :approval_required => false
    )
  end

  it "renders new phin_role form" do
    render
    
    response.should have_tag("form[action=?][method=post]", phin_roles_path) do
      with_tag("input#phin_role_name[name=?]", "phin_role[name]")
      with_tag("input#phin_role_approval_required[name=?]", "phin_role[approval_required]")
    end
  end
end


