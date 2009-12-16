=begin
    OpenPHIN is an opensource implementation of the CDC guidelines for 
    a public health information network.
    
    Copyright (C) 2009  Texas Association of Local Health Officials

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU Affero General Public License as
    published by the Free Software Foundation, either version 3 of the
    License, or (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU Affero General Public License for more details.

    You should have received a copy of the GNU Affero General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.

=end
require 'fastercsv'

class UserImporter
  def self.import_users(filename, options={})
    options = {:col_sep => "|", :row_sep => "\n", :update => false, :create => true, :default_jurisdiction => nil, :default_password => "Password1"}.merge(options)
    FasterCSV.open(filename, :headers => true, :col_sep => options[:col_sep], :row_sep => options[:row_sep]) do |records|
      records.each do |rec|
        email, first_name, last_name, display_name, jurisdiction, mobile, fax, phone = rec.values_at
        if email.blank?
          $stderr.puts rec.values_at.join("|")         
          next
        end
        if options[:update] && options[:create]
          user=User.find_or_create_by_email(email)
          user.update_password(options[:default_password],options[:default_password]) if user.new_record?          
        elsif options[:update]
          user=User.find_by_email(email)
          next if user.nil?
        elsif options[:create]
          user=User.new(:email => email)
          user.update_password(options[:default_password],options[:default_password])
        else
          raise "At least one of :update or :create must be true"
        end
        user.update_attributes(:first_name => first_name,
                               :last_name => last_name,
                               :display_name => display_name) if user.new_record?
        if user.valid?
          user.save
        else
          $stderr.puts rec.values_at.join("|")
          next
        end

        userdevices = user.devices
        user.devices << create_device(Device::PhoneDevice, :phone, mobile) unless mobile.blank? || userdevices.detect{|u| u.type == "Device::PhoneDevice" && u.phone == mobile}
        user.devices << create_device(Device::PhoneDevice, :phone, phone) unless phone.blank? || userdevices.detect{|u| u.type == "Device::PhoneDevice" && u.phone == phone}
        user.devices << create_device(Device::FaxDevice, :fax, fax) unless fax.blank?  || userdevices.detect{|u| u.type == "Device::FaxDevice" && u.fax == fax}
        j=Jurisdiction.find_by_name(jurisdiction)
        j=options[:default_jurisdiction] if j.nil? && options[:default_jurisdiction]
        user.role_memberships.create(:jurisdiction => j, :role => Role.public) unless j.nil? || user.jurisdictions.include?(j)
        user.save
      end
    end
  end

  def self.create_device(klass, method, value)
    dev=klass.new
    dev.send("#{method}=", value.strip)
    dev
  end
end
