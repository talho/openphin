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

FactoryGirl.define do

  factory :user do
    first_name "Default"
    sequence(:last_name) {|i| "FactoryUser#{i}"}
    display_name {|p| "#{p.first_name} #{p.last_name}"}
    sequence(:email) {|i| "user#{i}@example.com" }
    password              { "Password1" }
    password_confirmation { "Password1" }
    email_confirmed { true }
    role_requests_attributes { [] }
  end

  factory :jurisdiction do
    sequence(:name) {|jn| "Jurisdiction #{jn}"}
    foreign false
  end

  factory :organization do
    #org.approved true
    sequence(:name) {|jn| "Organization #{jn}"}
    distribution_email "dist@email.com"
    description "National Organization"
    phone "555-555-5555"
    fax "444-444-4444"
    street "123 Willow Ave. Suite 34"
    locality "Dallas"
    state "TX"
    postal_code "22212"
    foreign "false"
  end

  factory :organization_type do
    sequence(:name) {|jn| "Organization Type #{jn}"}

  end

  factory :role do
    ignore do
      application true
    end
    
    sequence(:name) {|r| "role#{r}"}
    public {true}
    after :build do |role, evaluator|
      role.app = App.where(name: evaluator.application || 'phin').first || create(:app, name: evaluator.application || 'phin')
    end
  end

  factory :app do
    sequence(:name) {|n| 'app #{n}'}
  end

  factory :alert do
    sequence(:title) {|t| "alert#{t}"}
    message "alertmessage"
    short_message ""
    audiences {|a| [a.association(:audience)] }
  end

  factory :han_alert do
    sequence(:title) {|t| "HAN alert#{t}"}
    message "alertmessage"
    short_message ""
    status 'Test'
    severity 'Moderate'
    delivery_time 60
    from_jurisdiction { FactoryGirl.create(:jurisdiction) }
    audiences {|a| [a.association(:audience)] }
  end

  factory :audience do
    users {|u| [u.association(:user)] }
  end

  factory :alert_attempt do
    alert {|t| t.association :alert}
    user {|t| FactoryGirl.create(:user)}
    requested_at Time.zone.now
  end

  factory :role_membership do
    association :user
    association :jurisdiction
    association :role
  end

  factory :role_request do
    association :user
    association :requester, :factory => :user
    association :jurisdiction
    association :role
  end

  factory :delivery do
    association :alert_attempt
    association :device
  end

  factory :email_device, :class => Device::EmailDevice do
    association :user
    sequence(:email_address) {|t| "EmailDevice#{t}@example.com"}
  end

  factory :phone_device, :class => Device::PhoneDevice do
    association :user
    sequence(:phone) {|t| "210-555-#{t.to_s.rjust(4,"0")}"}
  end

  factory :fax_device, :class => Device::FaxDevice do
    association :user
    sequence(:fax) {|t| "210-555-#{t.to_s.rjust(4,"0")}"}
  end

  factory :sms_device, :class => Device::SmsDevice do
    association :user
    sequence(:sms) {|t| "210-555-#{t.to_s.rjust(4,"0")}"}
  end

  factory :blackberry_device, :class => Device::BlackberryDevice do
    association :user
    sequence(:blackberry) {|t| "abcf#{t.to_s.rjust(4,"0")}"}
  end

  factory :im_device, :class => Device::ImDevice do
    association :user
    sequence(:im) {|t| "user#{t.to_s.rjust(4,"0")}@example.com"}
  end

  factory :article do
  	sequence(:title){|t| "Title ##{t}"}
  	sequence(:body){|t| "Sed ut perspiciatis unde omnis iste natus error sit voluptatem accusantium doloremque laudantium, totam rem aperiam, eaque ipsa quae ab illo inventore veritatis et quasi architecto beatae vitae dicta sunt explicabo. Nemo enim ipsam voluptatem quia voluptas sit aspernatur aut odit aut fugit, sed quia consequuntur magni dolores eos qui ratione voluptatem sequi nesciunt. Neque porro quisquam est, qui dolorem ipsum quia dolor sit amet, consectetur, adipisci velit, sed quia non numquam eius modi tempora incidunt ut labore et dolore magnam aliquam quaerat voluptatem. Ut enim ad minima veniam, quis nostrum exercitationem ullam corporis suscipit laboriosam, nisi ut aliquid ex ea commodi consequatur? Quis autem vel eum iure reprehenderit qui in ea voluptate velit esse quam nihil molestiae consequatur, vel illum qui dolorem eum fugiat quo voluptas nulla pariatur?"" ##{t}"}
  	sequence(:lede){|t| "Lede ##{t}"}
  end

  factory :group do
    sequence(:name){|t| "Name ##{t}"}
    association :owner, :factory => :user
  	scope "Personal"
  end

  factory :target do
    association :audience, :factory => :group
    association :item, :factory => :alert
  end

  factory :folder do
    sequence(:name){|t| "Folder ##{t}"}
    association :owner, :factory => :user
  end

  factory :document do
    association :owner, :factory => :user
    file {|f| File.open(__FILE__)}
  end

  factory :forum do
    sequence(:name) {|t| "Forum ##{t}"}
    association :audience
  end

  factory :topic do
    sequence(:name) {|t| "Topic ##{t}"}
    sequence(:content) {|t| "Topic desc ##{t}"}
    association :poster, :factory => :user
    association :forum
  end

  factory :comment, :class => Topic do
    sequence(:name) {|t| "Comment ##{t}"}
    sequence(:content) {|t| "Comment Contents ##{t}"}
    association :poster, :factory => :user
    association :forum
  end

  factory :favorite, :class => Favorite do
    tab_config  "{:id => 'test_favorite', :title =>'Test Favorite'}"
    association :user
  end

  factory :report_recipe, :class => RecipeExternal do
  end

  factory :report_report, :class => Report::Report do
    association :author, :factory => :user
    recipe "Report::RecipeExternal"
    incomplete :true
  end

  factory :dashboard do
    sequence(:name){|t| "Dashboard ##{t}"}
    columns 3
    draft_columns 3
  end

  factory :dashboard_portlet, :class => Dashboard::DashboardPortlet do
    association :dashboard
    association :portlet
    draft false
    column 0
  end

  factory :dashboard_audience, :class => Dashboard::DashboardAudience do
    association :dashboard
    association :audience
    role "publisher"
  end

  factory :portlet do
    xtype "dashboardhtmlportlet"
    config "--- \nhtml: \"\"\ncolumn: 0\nxtype: dashboardhtmlportlet\n"
  end

end