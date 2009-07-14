class Devices::EmailDevice < Device
  
  serialize :options
  option_accessor :email_address
end
