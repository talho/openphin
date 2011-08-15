class GenericMailer < ActionMailer::Base
  
  def mail(opts)
    bcc           opts[:recipients]
    from          opts[:from]
    reply_to      DO_NOT_REPLY
    subject       opts[:subject]
    content_type  "text/html"
    body          :html => opts[:body]
  end
  
end