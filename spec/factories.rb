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

Factory.sequence(:username) {|i| "user#{i}" }
Factory.define :phin_person do |pp|
  pp.first_name Factory.next(:username)
  pp.last_name "Smith"
  pp.email {|p| "#{p.first_name}@example.com"}
  pp.phin_oid {|p| p.first_name.to_phin_oid}
end
Factory.sequence(:jurisdiction_name) {|jn| "Jurisdiction #{jn}"}
Factory.define :phin_jurisdiction do |jur|
  jur.name Factory.next(:jurisdiction_name)

end
Factory.define :phin_organization, :parent => :phin_jurisdiction do |org|
  org.association :internal_jurisdiction, :factory => :phin_jurisdiction
  org.name Factory.next(:jurisdiction_name)
end
Factory.sequence(:rolename) {|r| "role#{r}"}
Factory.define :phin_role do |pr|
  pr.name Factory.next(:rolename)
  pr.approval_required false
end