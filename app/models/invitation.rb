# == Schema Information
#
# Table name: invitations
#
#  id              :integer(4)      not null, primary key
#  name            :string(255)
#  body            :text
#  organization_id :integer(4)
#  author_id       :integer(4)
#  subject         :string(255)
#  created_at      :datetime
#  updated_at      :datetime
#

class Invitation < ActiveRecord::Base
  
  has_many :invitees
  has_many :registered_users, :class_name => "User", :finder_sql =>
      'SELECT DISTINCT users.* FROM users, invitees WHERE users.email = invitees.email' +
      ' AND invitees.invitation_id = #{id} AND users.email_confirmed = true'
  has_many :registered_invitees, :class_name => "Invitee", :finder_sql =>
      'SELECT DISTINCT invitees.* FROM users, invitees WHERE users.email = invitees.email' +
      ' AND invitees.invitation_id = #{id}'
  belongs_to :default_organization, :class_name => "Organization", :foreign_key => "organization_id"
  belongs_to :author, :class_name => "User", :foreign_key => "author_id"

  validates_presence_of :author_id
  
  accepts_nested_attributes_for :invitees
  accepts_nested_attributes_for :default_organization

  def invitees_attributes=(attributes)
    attributes.each do |attr|
      invitees.build(attr.last) unless attr.last["email"].blank? || invitees.map(&:email).include?(attr.last["email"])
    end
  end

  def deliver
    deliver_status = Service::Email.deliver_invitation(self) unless new_invitees.empty?
    org_deliver_status = Service::Email.deliver_org_membership_notification(self) unless default_organization.nil? || registered_invitees.empty?
    if deliver_status.nil?
      org_deliver_status == "200 OK"
    elsif org_deliver_status.nil?
      deliver_status == "200 OK"
    else
      deliver_status == "200 OK" && org_deliver_status == "200 OK"
    end
  end

  def new_invitees
    invitees - registered_invitees
  end

  def registrations_complete_percentage
    pct = registered_users.size == 0 ? 0 : (registered_users.size.to_f / invitees.size.to_f) * 100
    pct.to_i
  end

  def registrations_complete_total
    registered_users.size
  end

  def registrations_incomplete_percentage
    pct = registered_users.size == 0 ? 0 : (registered_users.size.to_f / invitees.size.to_f) * 100
    100 - pct.to_i
  end

  def registrations_incomplete_total
    invitees.size - registered_users.size
  end

  handle_asynchronously :deliver
end
