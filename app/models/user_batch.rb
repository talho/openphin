class UserBatch
  
  DIRECTORY = File.join(Rails.root.to_s,'tmp','user_batch')
  
  attr_accessor :email          # submitter email
  attr_accessor :jurisdiction   # affected jurisdiction
  attr_accessor :file_data, :filename, :file_size, :content_type
  
  def initialize(attributes={})
    attributes.each do |k,v|
      if respond_to?(:"#{k}=")
        send(:"#{k}=", v)
      else
        raise(NoMethodError, "Unknown method #{k}, add it to the record attributes")
      end
    end
  end
  
  def file_data=(file_data)
    @file_data = file_data
    @original_filename = file_data.original_filename
    @file_size = file_data.size
    @content_type = file_data.content_type
  end
  
  def valid
    unless (submitter = User.find_by_email(@email))
      return "bad-email"
    end
    unless @jurisdiction.blank? || submitter.jurisdictions.find_by_name(@jurisdiction)
      return "bad-jurisdiction"
    end
    if binary?
      return "bad-file"
    end
    if file_data.blank?
      return 'empty-file-data'
    end
    return "valid"
  end
  
  def save
    if @file_data
      begin
        create_directory
        save_file
        pre_verify_csv(path)
        @file_data = nil
        self.delay.create_users(path)
        true
      rescue CSV::MalformedCSVError => msg
        false
      rescue Exception => e
        p e
        pp e.backtrace
        false
      end
    end
  end

  def create_users(path)
    begin
      submitter = User.find_by_email!(@email)
      jurisdiction = submitter.jurisdictions.find_by_name!(@jurisdiction) unless @jurisdiction.blank?
      f = File.open path
      f.close
      $stderr = StringIO.new
      UserImporter.import_users(path, :default_jurisdiction => jurisdiction, :create => true, :update => false)
      unless $stderr.string.empty?
        # error created during import, send email to submitter
        AppMailer.user_batch_error(@email, "during import", $stderr.string).deliver 
      end
      $stderr = STDERR
    rescue ActiveRecord::RecordNotFound => e
      unless submitter
        AppMailer.system_error(e, "Could not find submitter of #{@email}.").deliver
      else
        unless jurisdiction
          AppMailer.user_batch_error(@email, e, "Could not find the jurisdiction of #{@jurisdiction}.").deliver 
        end
      end
    rescue Errno::ENOENT
      AppMailer.system_error(e, "Could not find user batch file named #{path}.").deliver
    rescue StandardError => e
      AppMailer.system_error(e, "System Error, a batch file by #{@email} was not processed.").deliver 
    end
    archive_file
  end
  
  def binary?
    return false if self.file_data.is_a?(StringIO)
    # uses unix utility 'file' will not work on windows
    %x(file --mime-type #{self.file_data.path}) !~ /text/
  end

private

  def pre_verify_csv(path)
     CSV.open(path) do |records|
       records.each do |rec|  # This will error if CSV doesn't understand the file.
       end
     end
  end  

  def path
    File.join(DIRECTORY,@filename)
  end
    
  def save_file
    @filename = "#{@email}_#{@jurisdiction}_#{timestamp}.csv".gsub(/[^a-zA-Z0-9.]/, '_') # avoid unsupported filenames
    File.open(path,'wb') do |file|
      file.puts @file_data.read
    end
  end

  def create_directory
    FileUtils.mkdir_p DIRECTORY
  end
  
  def archive_file
    begin
      FileUtils.mkdir_p( File.join(DIRECTORY,'archive') )
      arc = File.join(DIRECTORY,'archive',@filename)
      FileUtils.mv path, arc
    rescue Exception => e
      AppMailer.system_error(e, "During archive, could not move #{path} to #{arc}.").deliver
    end
  end
  
  def timestamp
    n = Time.now
    "#{n.year}_#{n.mon}_#{n.day}_#{n.hour}_#{n.min}_#{n.sec}"
  end
    
end

