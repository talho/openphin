require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Report::Report do

  context "can" do
    it "associate with author and recipe" do
      report = Factory(:report_report)
      report.author.should be_an_instance_of User
      report.audience.should be_an_instance_of Audience
      report.audience.users.should have(1).user
      report.author.last_name.should match(/FactoryUser.*/)
      report.recipe.should be_an_instance_of Report::Recipe
      report.recipe.reports.should == [report]
    end
    it "form the recipe's json for the gui" do
      report = Factory(:report_report)
      json = report.as_json
      json.should be_kind_of(Hash)
      json.should have_key("report")
      report_derived = json["report"]
      report_derived.should have_key(%q(id))
      report_derived.should have_key(%q(author_id))
      report_derived.should have_key(%q(incomplete))
      report_derived.should have_key(%q(rendering_updated_at))
      report_derived.should have_key(%q(rendering_file_name))
      report_derived.should have_key(%q(rendering_file_size))
    end
  end

end
