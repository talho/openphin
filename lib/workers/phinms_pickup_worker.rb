class PhinmsPickupWorker < BackgrounDRb::MetaWorker
  set_worker_name :phinms_pickup_worker

  def create(args = nil)
  end

  def check(args = nil)
    if File.exist?(PHINMS_INCOMING)
      phindir=Dir.new PHINMS_INCOMING
      phindir.each do |file|
        filename = File.join(PHINMS_INCOMING, file)
        archive_filename = File.join(PHINMS_ARCHIVE, file)
        begin

          unless File.directory?( filename)
            xml= File.read(filename)
            if EDXL::MessageContainer.parse(xml).distribution_type == 'Ack'
              EDXL::AckMessage.parse(xml)
            else
              EDXL::Message.parse(xml)
            end
            File.mv( filename, archive_filename)
          end
        rescue Exception => e
          puts "error:#{filename}:#{archive_filename}\n#{e}"
        end
      end
    end
  end
end