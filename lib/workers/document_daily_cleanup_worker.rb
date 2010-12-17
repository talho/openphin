class DocumentDailyCleanupWorker < BackgrounDRb::MetaWorker
  set_worker_name :document_daily_cleanup_worker
  reload_on_schedule true

  def create(args = nil)
    # this method is called, when worker is loaded for the first time
  end

  def clean(args = nil)
    #find all folders for whom documents expire
    folders = Folder.scoped_by_expire_documents(true, :include => [:documents])
    #find all documents that are older than 30 days
    documents = folders.map {|f| f.documents.expired }.flatten
    #delete these documents
    documents.each { |doc| doc.destroy }

    #find all folders that expire and require notification
    notifying_folders = Folder.scoped_by_notify_before_document_expiry(true)
    #find all documents that are exactly 25 days old
    documents_expiring_soon = notifying_folders.map {|f| f.documents.expiring_soon(:include => :owner) }.flatten
    #notify users that these documents are going to expire soon

    users = documents_expiring_soon.map {|d| d.owner}.uniq

    users.each do |user|
      DocumentMailer.deliver_documents_soon_to_expire_warning(user)
    end
  end
end