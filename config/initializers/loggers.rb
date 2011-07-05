PHONE_LOGGER = Logger.new("#{RAILS_ROOT}/log/phone.log")
SWN_LOGGER = Logger.new("#{RAILS_ROOT}/log/swn.log")
PHINMS_RECEIVE_LOGGER = Logger.new("#{RAILS_ROOT}/log/phinms_pickup.log")
PHINMS_RECEIVE_LOGGER.level=Logger::WARN
ROLLCALL_LOGGER= Logger.new("#{RAILS_ROOT}/log/rollcall.log")
ROLLCALL_LOGGER.level=Logger::WARN

class ReportLogger < Logger
  def format_message(severity, timestamp, progname, msg)
    "#{timestamp.to_formatted_s(:db)} #{severity} #{msg}\n"
  end
end
REPORT_LOGGER= ReportLogger.new("#{RAILS_ROOT}/log/report.log")

