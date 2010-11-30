class UserBatch
  
  DIRECTORY = File.join(Rails.root,'tmp','user_batch')
  
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
    unless (jurisdiction = submitter.jurisdictions.find_by_name(@jurisdiction))
      return "bad-jurisdiction"
    end
    if binary?
      return "bad-file"
    end
    return "valid"
  end
  
  def save
    if @file_data
      begin
        create_directory
        save_file
        pre_verify_csv(path)
        self.send_later(:create_users,path)
        @file_data = nil
        true
      rescue FasterCSV::MalformedCSVError => msg
        false
      rescue
        false
      end
    end
  end

  def create_users(path)
    begin
      submitter = User.find_by_email!(@email)
      jurisdiction = submitter.jurisdictions.find_by_name!(@jurisdiction)
      f = File.open path
      f.close
      $stderr = StringIO.new
      UserImporter.import_users(
        path,
        :default_jurisdiction => jurisdiction,
        :create => true,
        :update => false,
        :default_password => "Password1"
        )
      unless $stderr.string.empty?
        # error created during import, send email to submitter
        AppMailer.deliver_user_batch_error(@email, "during import", $stderr.string) 
      end
      $stderr = STDERR
    rescue ActiveRecord::RecordNotFound => e
      unless submitter
        AppMailer.deliver_system_error(e, "Could not find submitter of #{@email}.")
      else
        unless jurisdiction
          AppMailer.deliver_user_batch_error(@email, e, "Could not find the jurisdiction of #{@jurisdiction}.") 
        end
      end
    rescue Errno::ENOENT
      AppMailer.deliver_system_error(e, "Could not find user batch file named #{path}.")
    rescue StandardError => e
      AppMailer.deliver_system_error(e, "System Error, a batch file by #{@email} was not processed.") 
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
     FasterCSV.open(path) do |records|
       records.each do |rec|  # This will error if FasterCSV doesn't understand the file.
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
      AppMailer.deliver_system_error(e, "During archive, could not move #{path} to #{arc}.")
    end
  end
  
  def timestamp
    n = Time.now
    "#{n.year}_#{n.mon}_#{n.day}_#{n.hour}_#{n.min}_#{n.sec}"
  end
    
end

