class GenericMailer < ActionMailer::Base
  
  def gen_mail(opts)
    @val = opts[:body]
    mail(bcc:        opts[:recipients],
      from:          opts[:from],
      reply_to:      DO_NOT_REPLY,
      subject:       opts[:subject]) do |format|
        format.html
      end
  end
  
end