class DocumentMailer < ActionMailer::Base
  
  def document(document, target)
    bcc target.users.map(&:formatted_email)
    from DO_NOT_REPLY
    subject "#{target.creator.name} shared a document with you"
    body :document => document
  end
  
  def channel_invitation(channel, target)
    bcc target.users.map(&:formatted_email)
    from DO_NOT_REPLY
    subject "#{target.creator.name} invited you to a channel"
    body :channel => channel
  end  
end