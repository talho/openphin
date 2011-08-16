PHONE_LOGGER = Logger.new("#{RAILS_ROOT}/log/phone.log", 3, 10 * 1024**2)
SWN_LOGGER = Logger.new("#{RAILS_ROOT}/log/swn.log", 3, 10 * 1024**2)
PHINMS_RECEIVE_LOGGER = Logger.new("#{RAILS_ROOT}/log/phinms_pickup.log", 3, 10 * 1024**2)
PHINMS_RECEIVE_LOGGER.level=Logger::WARN
ROLLCALL_LOGGER= Logger.new("#{RAILS_ROOT}/log/rollcall.log", 3, 10 * 1024**2)
ROLLCALL_LOGGER.level=Logger::WARN
LOGGER = Logger.new("#{RAILS_ROOT}/log/service.log", 3, 10 * 1024**2)
