class GenericMailer < ActionMailer::Base
  
  def mail(opts)
    recipients opts[:recipients]
    from opts[:from]
    reply_to DO_NOT_REPLY
    subject opts[:subject]
    body opts[:body]
  end
  
end