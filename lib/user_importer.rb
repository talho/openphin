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
  FIELDS = [ :email, :first_name, :last_name, :display_name, :jurisdiction, :mobile, :fax, :phone ].freeze

  def self.import_users(filename, options={})
    options = {:col_sep => ",", :row_sep => :auto, :update => false, :create => true, :default_jurisdiction => nil, :default_password => "Password1"}.merge(options)
    FasterCSV.open(filename, :headers => true, :col_sep => options[:col_sep], :row_sep => options[:row_sep]) do |records|
      records.each do |rec|
        email, first_name, last_name, display_name, jurisdiction, mobile, fax, phone = FIELDS.collect { |f| rec[f.to_s] }
        if email.blank?
          $stderr.puts "CSV File did not contain an email address for the user: \n" + 
            rec.values_at.join(",")  + 
            "\n This user was NOT created.\n\n"       
          next
        end
        if options[:update] && options[:create]
          user=User.find_or_create_by_email(email)
          user.update_password(options[:default_password],options[:default_password]) if user.new_record?          
        elsif options[:update]
          user=User.find_by_email(email)
          next if user.nil?
        elsif options[:create]
          user=User.find_by_email(email)
          next unless user.nil?
          user=User.new(:email => email)
          user.update_password(options[:default_password],options[:default_password])
        else
          raise "At least one of :update or :create must be true"
        end
        user.update_attributes(:first_name => first_name,
                               :last_name => last_name,
                               :display_name => display_name) if user.new_record?
        unless user.save && user.valid?
          $stderr.puts "CSV format appears invalid for the user: \n" + 
            rec.values_at.join(",") + 
            user.errors.full_messages.join(", ") +
            "\n This user was NOT created.\n\n"
          next
        end

        userdevices = user.devices
        unless mobile.blank? || userdevices.detect{|u| u.type == "Device::PhoneDevice" && u.phone == mobile}
          mobile_device = create_device(Device::PhoneDevice, :phone, mobile)
          user.devices << mobile_device if mobile_device.valid?
        end

        unless phone.blank? || userdevices.detect{|u| u.type == "Device::PhoneDevice" && u.phone == phone}
          phone_device = create_device(Device::PhoneDevice, :phone, phone)
          user.devices << phone_device if phone_device.valid?
        end

        unless fax.blank?  || userdevices.detect{|u| u.type == "Device::FaxDevice" && u.fax == fax}
          fax_device = create_device(Device::FaxDevice, :fax, fax)
          user.devices << fax_device if fax_device.valid?
        end

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

  def self.jurisdiction_transform(filename, options = {})
    options = {:col_sep => ",", :row_sep => :auto, :default_jurisdiction => "Texas"}.merge(options)
    FasterCSV.open(filename, :headers => true, :col_sep => options[:col_sep], :row_sep => options[:row_sep]) do |records|
      puts records.first.headers.join(",")
      records.each do |rec|
        email, first_name, last_name, display_name, jurisdiction, mobile, fax, phone = FIELDS.collect { |f| rec[f.to_s] }
        puts rec.values_at.join(",") if jurisdiction == options[:default_jurisdiction]
      end
    end
  end
end
