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

class OrgImporter
  def self.import_orgs(filename, options = {})
    newOrgs=File.open(filename).read.split("\r")
    
    newOrgs.each do|o|
      org = Organization.create! :name => o, :distribution_email => "abc@email.com", :postal_code => "22212", :phone => "555-555-5555", :street => "123 Willow Ave. Suite 34", :locality => "Dallas", :state => "TX", :description => "National Organization", :contact_display_name => "Bob Barker", :contact_email => "@bob@barker.com", :contact_phone => "555-555-5555"
      puts "preparing to save the records" ;
     org.save!

    end
  end
end


   