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
require 'factory_girl'

Factory.define :user do |pp|
  pp.first_name "John"
  pp.last_name "Smith"
  pp.display_name {|p| "#{p.first_name} #{p.last_name}"}
  pp.sequence(:email) {|i| "user#{i}@example.com" }
  pp.password              { "password" }
  pp.password_confirmation { "password" }
  pp.email_confirmed { true }
end

Factory.sequence(:jurisdiction_name) {|jn| "Jurisdiction #{jn}"}
Factory.define :jurisdiction do |jur|
  jur.name { Factory.next(:jurisdiction_name) }
end
Factory.define :organization do |org|
  org.approved true
  org.name { Factory.next(:jurisdiction_name) }
end
Factory.sequence(:rolename) {|r| "role#{r}"}
Factory.define :role do |pr|
  pr.name { Factory.next(:rolename) }
  pr.approval_required false
end

Factory.define :alert do |m|
  m.sequence(:title) {|t| "alert#{t}"}
  m.message "alertmessage"
  m.status 'Test'
  m.severity 'Moderate'
  m.delivery_time 60
  #  status      :string(255)
  #  acknowledge :boolean
  #  author_id   :integer
end

Factory.define :role_membership do |m|
  m.association :user
  m.association :jurisdiction
  m.association :role
end

Factory.define :role_request do |m|
  m.requester {|rr| rr.association :user }
  m.association :jurisdiction
  m.association :role
end