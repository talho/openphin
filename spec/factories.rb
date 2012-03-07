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
  pp.first_name "Default"
  pp.sequence(:last_name) {|i| "FactoryUser#{i}"}
  pp.display_name {|p| "#{p.first_name} #{p.last_name}"}
  pp.sequence(:email) {|i| "user#{i}@example.com" }
  pp.password              { "Password1" }
  pp.password_confirmation { "Password1" }
  pp.email_confirmed { true }
  pp.role_requests_attributes { [] }
end

Factory.sequence(:jurisdiction_name) {|jn| "Jurisdiction #{jn}"}
Factory.define :jurisdiction do |jur|
  jur.name { Factory.next(:jurisdiction_name) }
  jur.foreign false
end

Factory.sequence(:organization_name) {|jn| "Organization #{jn}"}
Factory.define :organization do |org|
  #org.approved true
  org.name { Factory.next(:organization_name) }
  org.distribution_email "dist@email.com"
  org.description "National Organization"
  org.phone "555-555-5555"
  org.fax "444-444-4444"
  org.street "123 Willow Ave. Suite 34"
  org.locality "Dallas"
  org.state "TX"
  org.postal_code "22212"
  org.foreign "false"
end

Factory.sequence(:organization_type_name) {|jn| "Organization Type #{jn}"}
Factory.define :organization_type do |org|
  org.name { Factory.next(:organization_type_name) }
end

Factory.sequence(:rolename) {|r| "role#{r}"}
Factory.define :role do |pr|
  pr.name { Factory.next(:rolename) }
  pr.approval_required {false}
  pr.application "phin"
end

Factory.define :alert do |m|
  m.sequence(:title) {|t| "alert#{t}"}
  m.message "alertmessage"
  m.short_message ""
  m.audiences {|a| [a.association(:audience)] }
end

Factory.define :han_alert do |m|
  m.sequence(:title) {|t| "HAN alert#{t}"}
  m.message "alertmessage"
  m.short_message ""
  m.status 'Test'
  m.severity 'Moderate'
  m.delivery_time 60
  m.from_jurisdiction { Factory(:jurisdiction) }
  m.audiences {|a| [a.association(:audience)] }
end

Factory.define(:audience) do |a|
  a.users {|u| [u.association(:user)] }
end

Factory.define :alert_attempt do |m|
  m.alert {|t| t.association :alert}
  m.user {|t| Factory(:user)}
  m.requested_at Time.zone.now
end

Factory.define :role_membership do |m|
  m.association :user
  m.association :jurisdiction
  m.association :role
end

Factory.define :role_request do |m|
  m.association :user
  m.association :requester, :factory => :user
  m.association :jurisdiction
  m.association :role
end

Factory.define :delivery do |m|
  m.association :alert_attempt
  m.association :device
end

Factory.define :email_device, :class => Device::EmailDevice do |m|
  m.association :user
  m.sequence(:email_address) {|t| "EmailDevice#{t}@example.com"}
end

Factory.define :phone_device, :class => Device::PhoneDevice do |m|
  m.association :user
  m.sequence(:phone) {|t| "210-555-#{t.to_s.rjust(4,"0")}"}
end

Factory.define :fax_device, :class => Device::FaxDevice do |m|
  m.association :user
  m.sequence(:fax) {|t| "210-555-#{t.to_s.rjust(4,"0")}"}
end

Factory.define :sms_device, :class => Device::SmsDevice do |m|
  m.association :user
  m.sequence(:sms) {|t| "210-555-#{t.to_s.rjust(4,"0")}"}
end

Factory.define :blackberry_device, :class => Device::BlackberryDevice do |m|
  m.association :user
  m.sequence(:blackberry) {|t| "abcf#{t.to_s.rjust(4,"0")}"}
end

Factory.define :im_device, :class => Device::ImDevice do |m|
  m.association :user
  m.sequence(:im) {|t| "user#{t.to_s.rjust(4,"0")}@example.com"}
end

Factory.define :article do |m|
	m.sequence(:title){|t| "Title ##{t}"}
	m.sequence(:body){|t| "Sed ut perspiciatis unde omnis iste natus error sit voluptatem accusantium doloremque laudantium, totam rem aperiam, eaque ipsa quae ab illo inventore veritatis et quasi architecto beatae vitae dicta sunt explicabo. Nemo enim ipsam voluptatem quia voluptas sit aspernatur aut odit aut fugit, sed quia consequuntur magni dolores eos qui ratione voluptatem sequi nesciunt. Neque porro quisquam est, qui dolorem ipsum quia dolor sit amet, consectetur, adipisci velit, sed quia non numquam eius modi tempora incidunt ut labore et dolore magnam aliquam quaerat voluptatem. Ut enim ad minima veniam, quis nostrum exercitationem ullam corporis suscipit laboriosam, nisi ut aliquid ex ea commodi consequatur? Quis autem vel eum iure reprehenderit qui in ea voluptate velit esse quam nihil molestiae consequatur, vel illum qui dolorem eum fugiat quo voluptas nulla pariatur?"" ##{t}"}
	m.sequence(:lede){|t| "Lede ##{t}"}
end

Factory.define :group do |m|
  m.sequence(:name){|t| "Name ##{t}"}
  m.association :owner, :factory => :user
	m.scope "Personal"
end

Factory.define :target do |m|
  m.association :audience, :factory => :group
  m.association :item, :factory => :alert
end

Factory.define :folder do |m|
  m.sequence(:name){|t| "Folder ##{t}"}
  m.association :owner, :factory => :user
end

Factory.define :document do |m|
  m.association :owner, :factory => :user
  m.file {|f| File.open(__FILE__)}
end

Factory.define :forum do |m|
  m.sequence(:name) {|t| "Forum ##{t}"}
  m.association :audience
end

Factory.define :topic do |m|
  m.sequence(:name) {|t| "Topic ##{t}"}
  m.sequence(:content) {|t| "Topic desc ##{t}"}
  m.association :poster, :factory => :user
  m.association :forum
end

Factory.define :comment, :class => Topic do |m|
  m.sequence(:name) {|t| "Comment ##{t}"}
  m.sequence(:content) {|t| "Comment Contents ##{t}"}
  m.association :poster, :factory => :user
  m.association :forum
end

Factory.define :favorite, :class => Favorite do |f|
  f.tab_config  "{:id => 'test_favorite', :title =>'Test Favorite'}"
  f.association :user
end

Factory.define :report_recipe, :class => Report::Recipe do |f|
end

Factory.define :report_report, :class => Report::Report do |f|
  f.association :author, :factory => :user
  f.recipe "Report::Recipe"
  f.incomplete :true
end

Factory.define :dashboard do |d|
  d.sequence(:name){|t| "Dashboard ##{t}"}
  d.columns 3
  d.draft_columns 3
end

Factory.define :dashboard_portlet, :class => Dashboard::DashboardPortlet do |dp|
  dp.association :dashboard
  dp.association :portlet
  dp.draft false
  dp.column 0
end

Factory.define :dashboard_audience, :class => Dashboard::DashboardAudience do |da|
  da.association :dashboard
  da.association :audience
  da.role "publisher"
end

Factory.define :portlet do |p|
  p.xtype "dashboardhtmlportlet"
  p.config "--- \nhtml: \"\"\ncolumn: 0\nxtype: dashboardhtmlportlet\n"
end