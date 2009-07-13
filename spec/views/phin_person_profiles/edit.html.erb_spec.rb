require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/phin_person_profiles/edit.html.erb" do
  include PhinPersonProfilesHelper
  
  before(:each) do
    assigns[:phin_person_profile] = @phin_person_profile = stub_model(PhinPersonProfile,
      :new_record? => false,
      :photo => ,
      :public => false,
      :credentials => "value for credentials",
      :employer => "value for employer",
      :experience => "value for experience",
      :bio => "value for bio"
    )
  end

  it "renders the edit phin_person_profile form" do
    render
    
    response.should have_tag("form[action=#{phin_person_profile_path(@phin_person_profile)}][method=post]") do
      with_tag('input#phin_person_profile_photo[name=?]', "phin_person_profile[photo]")
      with_tag('input#phin_person_profile_public[name=?]', "phin_person_profile[public]")
      with_tag('textarea#phin_person_profile_credentials[name=?]', "phin_person_profile[credentials]")
      with_tag('input#phin_person_profile_employer[name=?]', "phin_person_profile[employer]")
      with_tag('textarea#phin_person_profile_experience[name=?]', "phin_person_profile[experience]")
      with_tag('textarea#phin_person_profile_bio[name=?]', "phin_person_profile[bio]")
    end
  end
end


