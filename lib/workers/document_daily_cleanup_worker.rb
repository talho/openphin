class DocumentDailyCleanupWorker < BackgrounDRb::MetaWorker
  set_worker_name :document_daily_cleanup_worker
  reload_on_schedule true

  def create(args = nil)
    # this method is called, when worker is loaded for the first time
  end

  def clean(args = nil)
    #find all folders for whom documents expire
    Folder.find_each(:conditions => {:expire_documents => true}, :batch_size => 100) do |folder|
      #find all documents that are older than 30 days
      folder.documents.expired.each(&:destroy)
    end
  
    users = []
    #find all folders that expire and require notification
    Folder.find_each(:conditions => {:notify_before_document_expiry => true}, :batch_size => 100) do |folder|
      #find all documents that are exactly 25 days old
      users << folder.documents.expiring_soon.includes(:owner).map(&:owner)
    end
    
    #notify users that these documents are going to expire soon
    users.flatten.each do |user|
      DocumentMailer.documents_soon_to_expire_warning(user).deliver
    end
  end
end