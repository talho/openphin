class DocumentMailer < ActionMailer::Base
  
  def document(document, target, recipients)
    bcc recipients.map(&:formatted_email)
    from DO_NOT_REPLY
    subject "#{target.creator.name} shared a document with you"
    body :document => document
  end
  
end