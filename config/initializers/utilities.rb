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
require 'sha1'
module PHIN_support
  def to_phin_oid(type=1)
    digest=SHA1::hexdigest("#{self}--#{rand}--#{Time.now.to_f}")
    "#{PHIN_OID_ROOT}.#{type}.#{digest[0..7].hex}.#{digest[8..15].hex}.#{digest[16..23].hex}.#{digest[24..31].hex}"
  end
end
String.send(:include, PHIN_support)

Dir.class_eval <<-END
  def self.ensure_exists(dirname)
    dirname.split(File::SEPARATOR).inject{ |memo, dir|
      newdir=File.join(memo,dir)
      Dir.mkdir(newdir) unless File.exist?(newdir)
      newdir
    }
  end
END
