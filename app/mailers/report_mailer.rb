class ReportMailer < ActionMailer::Base
  default from: DO_NOT_REPLY

  def report_generated(report)
    @report = report

    mail(bcc: report.user.formatted_email,
         subject: "OpenPhin: Report \"#{report.class.name}\" has been generated on #{I18n.l Report.first.created_at}")
  end

  def report_error(email, report_name, exception_message, message="")
    @report_name = report_name
    @exception_message = exception_message
    @message = message

    mail(to: email,
         subject: "OpenPhin:  Report \"#{report_name}\" failed to generate")
  end

end
