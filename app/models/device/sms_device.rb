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

class Device::SMSDevice < Device

  option_accessor :sms
  validates_format_of :sms, :with => /^(1\s*[-\/\.]?)?(\((\d{3})\)|(\d{3}))\s*[-\/\.]?\s*(\d{3})\s*[-\/\.]?\s*(\d{4})\s*(([xX]|[eE][xX][tT])\.?\s*(\d+))*$/

  before_validation :strip_extra_characters

  def self.display_name
    'SMS'
  end

  def to_s
    super + ": #{sms}"
  end

  def deliver(alert)
    Service::SMS.deliver_alert(alert, user)
  end

  def self.batch_deliver(alert)
    Service::SMS.batch_deliver_alert(alert)
  end


  private
  def strip_extra_characters
    self.sms = self.sms.tr('()-. ','')
    self.sms = self.sms[1..-1] if self.sms.first == '1'
  end
end
