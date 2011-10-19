require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Reporters::Reporter do
  before(:each) do
    @current_user = Factory(:user)
    @recipe = Report::Recipe.find("Report::UserAllWithinJurisdictionsRecipe")
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
      report = @current_user.reports.complete.create(:recipe=>"Report::CocktailRecipe",:incomplete=>true)
      REPORT_LOGGER.should_receive(:info).with %Q(Report "#{report.name}" started.)
      REPORT_LOGGER.should_receive(:info).with %Q(Report "#{report.name}", Author is #{report.author.display_name})
      message = %Q(Report "#{report.name}" could not find #{report.recipe.demodulize})
      REPORT_LOGGER.should_receive(:fatal).with message
#      message_params = {:email=>report.author.email,:report_name=>report.name,:exception_message=>message}
      ReportMailer.should_receive(:deliver_report_error).with(report.author.email, report.name, message)
      Reporters::Reporter.new(:report_id=>report[:id]).perform
    end
  end

  context "succeed" do
    it "at building the supporting view" do
      pending "is verified at base recipe internals test"
    end
    it "at capturing the report data" do
      pending "is verified at base recipe internals test"
    end
    it "at generating the html renderings" do
      pending "is verified at base recipe internals test"
    end
    it "at marking the report complete" do
      pending "is verified at the base recipe internals test"
    end
  end

end

