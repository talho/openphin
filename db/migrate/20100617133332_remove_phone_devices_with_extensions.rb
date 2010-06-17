class RemovePhoneDevicesWithExtensions < ActiveRecord::Migration
  def self.up
    Device::PhoneDevice.all.each do |phone|
      phone.destroy unless phone.valid?
    end
    Device::FaxDevice.all.each do |fax|
      fax.destroy unless fax.valid?
    end
  end

  def self.down
  end
end
