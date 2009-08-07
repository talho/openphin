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

class Device < ActiveRecord::Base
  has_many :deliveries
  belongs_to :user
  
  named_scope :email, :conditions => "type = 'Device::EmailDevice'"
  named_scope :phone, :conditions => "type = 'Device::PhoneDevice'"
  
  serialize :options, Hash

  Types = [Device::EmailDevice, Device::PhoneDevice]

  def parent
    :user
  end

  def to_dsml(builder=nil)
    builder=Builder::XmlMarkup.new( :indent => 2) if builder.nil?
    builder.dsml(:entry, :dn => dn) do |entry|
      entry.dsml(:objectclass) do |oc|
        ocv="oc-value".to_sym
        oc.dsml ocv, "top"
        oc.dsml ocv, "organizationalUnit"
        oc.dsml ocv, "AlertCommunicationDevice"
      end
      entry.dsml(:attr, :name => :cn) {|a| a.dsml :value, cn}
      entry.dsml(:attr, :name => :description) {|a| a.dsml :value, description}
      entry.dsml(:attr, :name => :deviceName) {|a| a.dsml :value, deviceName}
      entry.dsml(:attr, :name => :deviceType) {|a| a.dsml :value, deviceType}
      entry.dsml(:attr, :name => :coverage) {|a| a.dsml :value, coverage}
      entry.dsml(:attr, :name => :emailAddress) {|a| a.dsml :value, mail}
      entry.dsml(:attr, :name => :areaCode) {|a| a.dsml :value, areaCode}
      entry.dsml(:attr, :name => :exchnage) {|a| a.dsml :value, exchange}
      entry.dsml(:attr, :name => :line) {|a| a.dsml :value, line}
      entry.dsml(:attr, :name => :rank) {|a| a.dsml :value, rank}
      entry.dsml(:attr, :name => :pin) {|a| a.dsml :value, pin}
      entry.dsml(:attr, :name => :countryPrefix) {|a| a.dsml :value, countryPrefix}
      entry.dsml(:attr, :name => :internationalNumber) {|a| a.dsml :value, internationalNumber}
      entry.dsml(:attr, :name => :emergencyUseInd) {|a| a.dsml :value, emergencyUseInd}
      entry.dsml(:attr, :name => :homeInd) {|a| a.dsml :value, homeInd}
    end
  end
end


