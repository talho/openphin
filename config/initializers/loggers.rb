PHONE_LOGGER = Logger.new("#{RAILS_ROOT}/log/phone.log")
PHINMS_RECEIVE_LOGGER = Logger.new("#{RAILS_ROOT}/log/phinms_pickup.log")
PHINMS_RECEIVE_LOGGER.level=Logger::WARN
ROLLCALL_LOGGER= Logger.new("#{RAILS_ROOT}/log/rollcall.log")
ROLLCALL_LOGGER.level=Logger::WARN
