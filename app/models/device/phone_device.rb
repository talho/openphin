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
  validates_format_of :phone, :with => /^(1\s*[-\/\.]?)?(\((\d{3})\)|(\d{3}))\s*[-\/\.]?\s*(\d{3})\s*[-\/\.]?\s*(\d{4})\s*$/
  before_validation :strip_extra_characters

  def self.display_name
    'Phone'
  end

  def to_s
    super + ": #{phone}"
  end

  def key
    :phone
  end

  private
  def strip_extra_characters
    return if self.phone.blank?
    self.phone = self.phone.tr('()-. ','')
    self.phone = self.phone[1..-1] if self.phone.first == '1'
  end
end
