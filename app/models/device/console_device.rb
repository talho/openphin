class Device::ConsoleDevice
  def self.display_name
    'Console'
  end

  def deliver(alert)
    #intentionally do nothing
  end

  def self.batch_deliver(alert)
    #intentionally do nothing
  end
end
