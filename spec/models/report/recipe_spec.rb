require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

require File.expand_path(File.join(File.dirname(__FILE__),"..","..","..","db","fixtures","jurisdictions"))
require File.expand_path(File.join(File.dirname(__FILE__),"..","..","..","db","fixtures","roles"))

describe "Released" do
  before(:each) do
    User.all.map(&:destroy)
  end
  Recipe::Recipe.all.map(&:name).grep(/Recipe$/).each do |id|
#    puts "Testing #{id} for basic structual aspects"
    it "#{id} holds a empty helper array" do
      recipe = id.constantize
      recipe.helpers.present? == true
    end
    it "#{id} holds a description string" do
      recipe = id.constantize
      recipe.description.should be_an_instance_of String
    end
    it "#{id} holds a template path" do
      recipe = id.constantize
      recipe.template_path.should match(/html\.erb$/)
    end
    it "#{id} holds a layout path" do
      recipe = id.constantize
      recipe.layout_path.should be_an_instance_of String
    end
    it "#{id} humanizes its class name" do
      recipe = id.constantize
      recipe.humanized(recipe.name).should match("Recipe")
    end
    it "#{id} forms the recipe's json for the gui" do
      recipe = id.constantize
      json = recipe.as_json
      json.should be_kind_of Hash
      json.should have_key(:id)
      json[:id].should == recipe.name
    end
  end

  Recipe::Recipe.selectable.map(&:name).grep(/Recipe$/).each do |id|
#    puts "Testing #{id} for data capturing operations"
    it "#{id} captures data to a file" do
      report = FactoryGirl.create(:report_report,:recipe=>id)
      report.dataset.should_receive(:insert).at_least(:once).with(any_args())
      recipe = id.constantize
      recipe.capture_to_db report
    end
    it "#{id} captures data to the report as a resultset and generates the html to the report as a rendering" do
#      report = FactoryGirl.create(:report_report)
      current_user = FactoryGirl.create(:user)
      report = current_user.reports.create!(:recipe=>id,:incomplete=>true)
#      Reporters::Reporter.new(:report_id=>report[:id]).perform
      recipe = id.constantize

      recipe.capture_to_db report
      dataset = report.dataset
      dataset.should be_an_instance_of Mongo::Collection
      values = dataset.instance_values
      values["name"].should match /Recipe-/
      values.find().should be_an_instance_of Enumerable::Enumerator

      # Reporter does this
#      view = ActionView::Base.new( Rails::Configuration.new.view_path )
#      recipe.generate_rendering_of_on_with(report,view,File.read(recipe.template_path))
#      rendering = report.rendering
#      rendering.should be_an_instance_of(Paperclip::Attachment)
#      values = rendering.instance_values
#      values["_rendering_file_name"].should match("#{report.name}.html")
#      values["_rendering_content_type"].should match("text/html")
#      values["_rendering_updated_at"].should <= Time.now
#      values["errors"].should be_empty
#      values["instance"].should == report
#      values["instance"]["rendering_file_size"].should > 0
#      values["instance"][:incomplete].should be_false
    end
  end

  after(:all) do
    # this assures the deletion of the paperclip files
    Recipe::Report.all.map(&:destroy)
  end

end

