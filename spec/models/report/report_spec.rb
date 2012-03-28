require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Report::Report do

  id = Recipe::Recipe.selectable.map(&:name).grep(/Recipe$/).first

  context "can" do
    it "associate with author and recipe" do
      report = FactoryGirl.create(:report_report,:recipe=>id)
      report.author.should be_an_instance_of User
      report.author.last_name.should match(/FactoryUser.*/)
    end
    it "form the recipe's json for the gui" do
      report = FactoryGirl.create(:report_report,:recipe=>id)
      json = report.as_json
      json.should be_kind_of(Hash)
      json.should have_key("id")
      json["id"].should == report[:id]
    end
  end

  context "can not" do
    it "create a report with using a non-existent recipe" do
#      report = FactoryGirl.create(:report_report,:recipe=>"Report::MartiniRecipe")
      @current_user = FactoryGirl.create(:user)
      report = @current_user.reports.create(:recipe=>"Recipe::MartiniRecipe",:incomplete=>true)
      report[:id].should be_nil
    end
  end


end


