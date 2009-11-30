# == Schema Information
#
# Table name: devices
#
#  id            :integer(4)      not null, primary key
#  user_id       :integer(4)
#  type          :string(255)
#  description   :string(255)
#  name          :string(255)
#  coverage      :string(255)
#  emergency_use :boolean(1)
#  home_use      :boolean(1)
#  options       :text
#

class Device::EmailDevice < Device
  
  option_accessor :email_address
  
  validates_presence_of     :email_address
  validates_format_of       :email_address, :with => %r{^(?:[a-zA-Z0-9_'^&amp;/+-])+(?:\.(?:[a-zA-Z0-9_'^&amp;/+-])+)*@(?:(?:\[?(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?))\.){3}(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\]?)|(?:[a-zA-Z0-9-]+\.)+(?:[a-zA-Z]){2,}\.?)$}

  def self.display_name
    'E-mail'
  end
  
  def to_s
    super + ": #{email_address}"
  end
  
  def deliver(alert)
    AlertMailer.deliver_alert(alert, user) unless alert.alert_attempts.nil?
  end
  
  def self.batch_deliver(alert)
    AlertMailer.deliver_batch_alert(alert) unless alert.alert_attempts.nil?
  end
end
