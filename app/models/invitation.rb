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
  has_many :registered_users, :class_name => "User", :finder_sql => "SELECT users.* FROM users, invitees, invitations  WHERE (`users`.email = `invitees`.email AND `invitees`.invitation_id = `invitations`.id)"
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
    Service::Email.deliver_invitation(self)
  end

end
