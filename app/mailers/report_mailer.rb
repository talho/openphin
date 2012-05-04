class ReportMailer < ActionMailer::Base
  default from: DO_NOT_REPLY
  
  def report_generated(email,report_name)
    @report_name = report_name
    
    mail(bcc: email,
         subject: "TxPhin: Report \"#{report_name}\" has been generated")
  end

  def report_error(email, report_name, exception_message, message="")
    @report_name = report_name
    @exception_message = exception_message
    @message = message
    
    mail(to: email,
         subject: "TxPhin:  Report \"#{report_name}\" failed to generate")
  end

end




