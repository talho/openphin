require File.dirname(__FILE__) + '/../../spec_helper'

describe 'alerts/new.html.erb' do

  before do
    @alert = Alert.new
    assigns[:alert] = @alert
  end
  
  def render
    super 'alerts/new.html.erb'
  end
  
  it "should have a check box for E-mail" do
    render
    response.should have_tag('input#?[type=checkbox][name=?]', 'alert_device_email_device', 'alert[device_types][]')
    response.should have_tag('label[for=?]', 'alert_device_email_device')
  end
  
end
