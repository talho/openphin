require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/phin_people/edit.html.erb" do
  include PhinPeopleHelper
  
  before(:each) do  
    assigns[:phin_person] = Factory(:phin_person)
    
  end

  it "renders the edit phin_person form" do
    render
    
    response.should have_tag("form[action=#{phin_person_path(@phin_person)}][method=post]") do
    end
  end
end


