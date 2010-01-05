class DocumentMailer < ActionMailer::Base
  
  def document(document, target)
    bcc target.users.map(&:formatted_email)
    from DO_NOT_REPLY
    subject "#{target.creator.name} sent a document to you"
    body :document => document
  end
  
  def channel_invitation(channel, target)
    bcc target.users.map(&:formatted_email)
    from DO_NOT_REPLY
    subject "#{target.creator.name} invited you to a share"
    body :channel => channel
  end
  
  def document_addition(channel, document)
    bcc channel.users.map(&:formatted_email)
    from DO_NOT_REPLY
    subject %Q{A document has been added to the share "#{channel}"}
    body :channel => channel, :document => document
  end
  
  def document_update(document, users, channel)
    bcc users.map(&:formatted_email)
    from DO_NOT_REPLY
    subject "A document has been updated"
    body :document => document, :channel => channel
  end
end