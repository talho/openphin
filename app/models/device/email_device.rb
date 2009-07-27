# == Schema Information
#
# Table name: devices
#
#  id            :integer         not null, primary key
#  user_id       :integer
#  type          :string(255)
#  description   :string(255)
#  name          :string(255)
#  coverage      :string(255)
#  emergency_use :boolean
#  home_use      :boolean
#  options       :text
#

class Device::EmailDevice < Device
  
  serialize :options
  option_accessor :email_address
  
  validates_presence_of     :email_address
  validates_format_of       :email_address, :with => %r{.+@.+\..+}
  
  def self.display_name
    'E-mail'
  end
  
  def deliver(alert)
    AlertMailer.deliver_alert(alert, user, self)
  end
end
