class DocumentMailer < ActionMailer::Base
  
  def document(document, target)
    bcc target.users.reject{|user| user.roles.length == 1 && user.roles.include?(Role.public)}.map(&:formatted_email)
    from DO_NOT_REPLY
    subject "#{target.creator.name} sent a document to you"
    body :document => document, :target => target
  end
  
  def share_invitation(folder, target)
    bcc target[:users].reject{|user| user.roles.length == 1 && user.roles.include?(Role.public)}.map(&:formatted_email)
    from DO_NOT_REPLY
    subject "#{target[:creator].name} has added you to the shared folder \"#{folder.name}\""
    body :folder => folder, :target => target
  end

  def document_viewed(document, user)
    recipients document.owner.formatted_email
    from DO_NOT_REPLY
    subject "#{user.display_name} has downloaded the document #{document.file_file_name}."
    body :document => document, :user => user
  end

  def document_addition(document, user)
    users = document.audience.recipients.reject{|u| u.roles.length == 1 && u.roles.include?(Role.public)}
    users << document.folder.owner
    users.delete(user)

    bcc users.map(&:formatted_email)
    from DO_NOT_REPLY
    subject %Q{A document has been added to the shared folder "#{document.folder.name}"}
    body :share => document.folder, :document => document, :current_user => user
  end
  
  def document_update(document, user)
    users = document.audience.recipients.reject{|u| u.roles.length == 1 && u.roles.include?(Role.public)}
    users << document.folder.owner
    users.delete(user)

    bcc users.map(&:formatted_email)
    from DO_NOT_REPLY
    subject %Q{The document "#{document.file_file_name}" has been updated.}
    body :document => document, :share => document.folder, :current_user => user
  end

  def documents_soon_to_expire_warning(user)
    recipients user.formatted_email
    from DO_NOT_REPLY
    subject "Some of your PHIN documents are soon to expire."
    body :user => user
  end
end