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
        xml= File.read(filename)
        begin
          unless File.directory?( filename)
            if EDXL::MessageContainer.parse(xml).distribution_type == 'Ack'
              PHINMS_RECEIVE_LOGGER.debug "Parsing acknowledgement"
              ack=EDXL::AckMessage.parse(xml)
              PHINMS_RECEIVE_LOGGER.debug "Acknowledgement parsed: #{ack.distribution_id}"
            else
              PHINMS_RECEIVE_LOGGER.debug "Parsing cascade message"
              EDXL::Message.parse(xml)
              PHINMS_RECEIVE_LOGGER.debug "Cascade Message Parsed: #{msg.distribution_id}"
            end
            File.mv( filename, archive_filename)
          end
        rescue Exception => e
          PHINMS_RECEIVE_LOGGER.error "Error parsing PHIN-MS message:\n#{e}\n#{xml}"
          AppMailer.deliver_system_error(e, "Filename: #{filename}\nContents:\n#{xml}")
        end
      end
    end
  end
end