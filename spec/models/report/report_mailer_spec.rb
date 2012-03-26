require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe ReportMailer do
  before(:each) do
    @email = 'YourAddress@Example.com'
    @report_name = 'TheForgottenRecipe-45'
    @error_message = 'The report on this recipe is missing'
    @generated_notify = ReportMailer.report_generated(@email, @report_name).deliver
    @error_notify = ReportMailer.report_error(@email, @report_name, @error_message).deliver
  end

  context "creates a report generated email notification" do
    it "sent to the email address" do
      @error_notify.to.first.should match(/#{@email}/)
    end
    it "with a subject" do
      @error_notify.subject.should  match(/#{@report_name}/)
    end
  end

  context "creates a error email notification" do
    it "sent to the email address" do
      @error_notify.to.first.should match(/#{@email}/)
    end
    it "with a subject" do
      @error_notify.subject.should  match(/#{@report_name}/)
    end
    it "with a body" do
      @error_notify.body.should match(/#{@error_message}/)
    end
  end

end

