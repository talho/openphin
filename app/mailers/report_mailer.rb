class ReportMailer < ActionMailer::Base

  def report_generated(email,report_name)
    bcc  email
    from DO_NOT_REPLY
    subject "TxPhin: Report \"#{report_name}\" has been generated"
    body :report_name => report_name
  end

  def report_error(email, report_name, exception_message, message="")
    recipients email
    from DO_NOT_REPLY
    subject "TxPhin:  Report \"#{report_name}\" failed to generate"
    body :report_name => report_name, :exception_message => exception_message, :message => message
  end

end




