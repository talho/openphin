require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/phin_person/new" do
  before(:each) do
    render 'phin_person/new'
  end
  
  #Delete this example and add some real ones or delete this file
  it "should render a form tag" do
    response.should have_tag('form')
  end
end
