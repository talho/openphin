class DocumentMailer < ActionMailer::Base
  default from: DO_NOT_REPLY
  
  def document(document, target)
    @document = document
    @target = target
    mail(bcc: target.users.reject{|user| user.roles.length == 1 && user.roles.include?(Role.public)}.map(&:formatted_email).compact,
         subject: "#{target.creator.name} sent a document to you")
  end
  
  def share_invitation(folder, target)
    @folder = folder
    @target = target
    
    mail(bcc: target[:users].reject{|user| user.roles.length == 1 && user.roles.include?(Role.public)}.map(&:formatted_email).compact,
         subject: "#{target[:creator].name} has added you to the shared folder \"#{folder.name}\"")
  end

  def document_viewed(document, user)
    @document = document
    @user = user
    
    mail(to: document.owner.formatted_email,
         subject: "#{user.display_name} has downloaded the document #{document.file_file_name}.")
  end

  def document_addition(document, user)
    users = document.audience.nil? ? [] : document.audience.recipients.reject{|u| u.roles.length == 1 && u.roles.include?(Role.public)}
    users << document.folder.owner unless document.folder.owner.nil?
    users.delete(user)

    @share = document.folder
    @document = document
    @current_user = user
    
    mail(bcc: users.compact.map(&:formatted_email).compact,
         subject: %Q{A document has been added to the shared folder "#{document.folder.name}"})
  end
  
  def document_update(document, user)
    users = document.audience.recipients.reject{|u| u.roles.length == 1 && u.roles.include?(Role.public)}
    users << document.folder.owner unless document.folder.owner.nil?
    users.delete(user)

    @document = document
    @share = document.folder
    @current_user = user
    
    mail(bcc: users.compact.map(&:formatted_email).compact,
         subject: %Q{The document "#{document.file_file_name}" has been updated.})
  end

  def documents_soon_to_expire_warning(user)
    @user = user
    
    mail(to: user.formatted_email,
         subject: "Some of your PHIN documents are soon to expire.")
  end
end