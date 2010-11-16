class DocumentMailer < ActionMailer::Base
  
  def document(document, target)
    bcc target.users.reject{|user| user.roles.length == 1 && user.roles.include?(Role.public)}.map(&:formatted_email)
    from DO_NOT_REPLY
    subject "#{target.creator.name} sent a document to you"
    body :document => document, :target => target
  end
  
  def share_invitation(share, target)
    bcc target[:users].reject{|user| user.roles.length == 1 && user.roles.include?(Role.public)}.map(&:formatted_email)
    from DO_NOT_REPLY
    subject "#{target[:creator].name} invited you to a share"
    body :share => share, :target => target
  end
  
  def document_addition(share, document)
    bcc share.audience.recipients.reject{|user| user.roles.length == 1 && user.roles.include?(Role.public)}.map(&:formatted_email)
    from DO_NOT_REPLY
    subject %Q{A document has been added to the share "#{share}"}
    body :share => share, :document => document
  end
  
  def document_update(document, users, share)
    bcc users.reject{|user| user.roles.length == 1 && user.roles.include?(Role.public)}.map(&:formatted_email)
    from DO_NOT_REPLY
    subject "A document has been updated"
    body :document => document, :share => share
  end
end