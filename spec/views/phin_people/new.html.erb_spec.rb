require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/phin_people/new.html.erb" do
  include PhinPeopleHelper
  
  before(:each) do
    assigns[:phin_person] = stub_model(PhinPerson,
      :new_record? => true,:id => "1"
    )
  end

  it "renders new phin_person form" #do
  #  render
  #
  #  response.should have_tag("form[action=?][method=post]", phin_people_path)
  #  response.should have_tag("input[name=?]", "phin_person[cn]")
  #
  #end
end


