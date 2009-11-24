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

class Device::FaxDevice < Device

  option_accessor :fax
  validates_format_of :fax, :with => /^(1\s*[-\/\.]?)?(\((\d{3})\)|(\d{3}))\s*[-\/\.]?\s*(\d{3})\s*[-\/\.]?\s*(\d{4})\s*(([xX]|[eE][xX][tT])\.?\s*(\d+))*$/

  before_save :strip_extra_characters

  def self.display_name
    'Fax'
  end

  def to_s
    super + ": #{fax}"
  end

  def deliver(alert)
    Service::Fax.deliver_alert(alert, user)
  end

  def self.batch_deliver(alert)
    Service::Fax.batch_deliver_alert(alert)
  end

  private
  def strip_extra_characters
    self.fax = self.fax.tr('()-. ','')
    self.fax = self.fax[1..-1] if self.fax.first == '1'
  end
end
