PHONE_LOGGER = Logger.new("#{RAILS_ROOT}/log/phone.log")
PHINMS_RECEIVE_LOGGER = Logger.new("#{RAILS_ROOT}/log/phinms_pickup.log")
PHINMS_RECEIVE_LOGGER.level=Logger::WARN
