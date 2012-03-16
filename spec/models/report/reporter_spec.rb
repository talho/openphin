require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Reporters::Reporter do
  before(:each) do
    User.all.map(&:destroy)
    @current_user = Factory(:user)
    @recipe = Recipe.find("Recipe::UserAllWithinJurisdictionsRecipe")
    ActionMailer::Base.delivery_method = :test
    ActionMailer::Base.perform_deliveries = true
    ActionMailer::Base.deliveries = []
  end

  context "aborts, logs fatal message and mails a report error email" do
    it "for a non-integer report_id" do
      report_id = "DirtyDog"
      message = "Reporter could not find report with report_id of #{report_id}"
      REPORT_LOGGER.should_receive(:fatal).with message
      AppMailer.should_receive(:deliver_system_error).with message
      Reporters::Reporter.new(:report_id=>report_id).perform
    end
    it "on a non-existent report" do
      report_id = 999
      message = "Reporter could not find report with report_id of #{report_id}"
      REPORT_LOGGER.should_receive(:fatal).with message
      AppMailer.should_receive(:deliver_system_error).with message
      Reporters::Reporter.new(:report_id=>report_id).perform
    end
    it "on a non-existent author" do
      report = @current_user.reports.complete.create(:recipe=>@recipe.name,:incomplete=>true)
      @current_user.destroy
      REPORT_LOGGER.should_receive(:info).with %Q(Report "#{report.name}" started.)
      message = %Q(Report "#{report.name}" could not find author with id of #{report.author_id})
      REPORT_LOGGER.should_receive(:fatal).with message
      AppMailer.should_receive(:deliver_system_error).with message
      Reporters::Reporter.new(:report_id=>report[:id]).perform
    end
    it "on a non-existent recipe" do
      report = @current_user.reports.create(:recipe=>"Recipe::CocktailRecipe",:incomplete=>true)
      report.should_not be_valid
    end
  end

end

