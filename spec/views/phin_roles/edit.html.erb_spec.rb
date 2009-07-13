require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/phin_roles/edit.html.erb" do
  include PhinRolesHelper
  
  before(:each) do
    assigns[:phin_role] = @phin_role = stub_model(PhinRole,
      :new_record? => false,
      :name => "value for name",
      :approval_required => false
    )
  end

  it "renders the edit phin_role form" do
    render
    
    response.should have_tag("form[action=#{phin_role_path(@phin_role)}][method=post]") do
      with_tag('input#phin_role_name[name=?]', "phin_role[name]")
      with_tag('input#phin_role_approval_required[name=?]', "phin_role[approval_required]")
    end
  end
end


