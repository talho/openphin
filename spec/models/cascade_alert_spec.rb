require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe CascadeHanAlert do
  before do
    @jurisdiction = FactoryGirl.create(:jurisdiction)
    FactoryGirl.create(:jurisdiction).move_to_child_of(@jurisdiction)
    @cascade_alert = CascadeHanAlert.new(FactoryGirl.create(:han_alert, :author => FactoryGirl.create(:user)))
  end
  
  describe 'to_edxl' do
    
    it "should not blow up" do
      lambda {@cascade_alert.to_edxl}.should_not raise_error
    end
    
  end
end
