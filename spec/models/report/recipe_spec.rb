require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

require File.expand_path(File.join(File.dirname(__FILE__),"..","..","..","db","fixtures","jurisdictions"))
require File.expand_path(File.join(File.dirname(__FILE__),"..","..","..","db","fixtures","roles"))

describe Report::Recipe do

  context "holds" do
    it "a empty helper array" do
      recipe = Factory(:report_recipe,:type=>"Report::Recipe")
      recipe.helpers.empty? == true
    end
    it "a description string" do
      recipe = Factory(:report_recipe,:type=>"Report::Recipe")
      recipe.description.should match(/Base Recipe/)
    end
    it "a template path" do
      recipe = Factory(:report_recipe,:type=>"Report::Recipe")
      recipe.template_path.should match(/html\.erb$/)
    end
  end

  context "can" do
    it "humanizes its class name" do
      recipe = Factory(:report_recipe,:type=>"Report::Recipe")
      recipe.type_humanized.should match("Recipe")
    end
    it "form the recipe's json for the gui" do
      recipe = Factory(:report_recipe,:type=>"Report::Recipe")
      json = recipe.as_json
      json.should be_kind_of Hash
      json.should have_key("id")
      json["id"].should equal(recipe[:id])
    end
    it "create a recipe model for future association to reports" do
      before = Report::Recipe.count
      Report::Recipe.find_or_create.should be_an_instance_of Report::Recipe
      (Report::Recipe.count - before).should be 1
    end
    it "create recipe models for all the recipe model files present" do
      before = Report::Recipe.count
      Report::Recipe.register_recipes
      (Report::Recipe.count - before).should be > 0
    end
    it "capture data to a file" do
      recipe = Factory(:report_recipe,:type=>"Report::Recipe")
      report = Factory(:report_report)
      report.dataset.should_receive(:insert).with(any_args())
      recipe.capture_to_db report
    end
    it "capture data to the report as a resultset and generate the html to the report as a rendering" do
      report = Factory(:report_report)
      recipe = report.recipe

      recipe.capture_to_db report
      dataset = report.dataset
      dataset.should be_an_instance_of Mongo::Collection
      values = dataset.instance_values
      values["name"].should match /-Recipe-/
      values.find().should be_an_instance_of Enumerable::Enumerator
      report.incomplete.should be_false

      # Reporter does this
      view = ActionView::Base.new( Rails::Configuration.new.view_path )

      recipe.generate_rendering_of_on_with(report,view,File.read(recipe.template_path))
      rendering = report.rendering
      rendering.should be_an_instance_of(Paperclip::Attachment)
      values = rendering.instance_values
      values["_rendering_file_name"].should match("#{report.name}.html")
      values["_rendering_content_type"].should match("text/html")
      values["_rendering_updated_at"].should <= Time.now
      values["errors"].should be_empty
      values["instance"].should == report
      values["instance"]["rendering_file_size"].should > 0
      values["instance"][:incomplete].should be_false
    end

    after(:all) do
      # this assures the deletion of the paperclip files
      Report::Report.all.map(&:destroy)
    end
  end

end
