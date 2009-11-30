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

class Device::PhoneDevice < Device

  option_accessor :phone
  validates_format_of :phone, :with => /^(1\s*[-\/\.]?)?(\((\d{3})\)|(\d{3}))\s*[-\/\.]?\s*(\d{3})\s*[-\/\.]?\s*(\d{4})\s*(([xX]|[eE][xX][tT])\.?\s*(\d+))*$/
  before_validation :strip_extra_characters

  def self.display_name
    'Phone'
  end

  def to_s
    super + ": #{phone}"
  end

  def deliver(alert)
    Service::Phone.deliver_alert(alert, user)
  end

  def self.batch_deliver(alert)
    Service::Phone.batch_deliver_alert(alert)
  end

  private
  def strip_extra_characters
    self.phone = self.phone.tr('()-. ','')
    self.phone = self.phone[1..-1] if self.phone.first == '1'
  end
end
