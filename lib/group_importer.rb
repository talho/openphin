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

class GroupImporter
  def self.import_groups(filename, options = {})
    options = {:col_sep => "|", :row_sep => "\n"}.merge(options)
    FasterCSV.open(filename, :headers => true, :col_sep => options[:col_sep], :row_sep => options[:row_sep]) do |records|
      records.each do |rec|
        email = rec['email'].strip
        jurisdiction = rec['jurisdiction'].strip
        group_name = rec['group_name'].strip
        if email.blank?
          STDERR.puts rec.values_at.join("|")
          next
        end
        user=User.find_by_email(email)
        next if user.nil?
        jur = Jurisdiction.find_by_name(jurisdiction)
        next if jur.nil?
        group = Group.find_by_name_and_owner_jurisdiction_id(group_name, jur.id)
        if group.nil?
          admin = jur.alerting_users.first
          admin = Jurisdiction.find_by_name("Texas").alerting_users.first if admin.nil?
          group = Group.create(:name => group_name, :owner_jurisdiction_id => jur.id, :scope => "Jurisdiction", :owner_id => admin.id)
        end
        next if group.nil?
        group.users << user if group.new_record? || options[:no_update].blank?
        group.save!
      end
    end
  end
end
