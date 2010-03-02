class Invitation < ActiveRecord::Base
  
  has_many :invitees
  has_many :registered_users, :class_name => "User", :finder_sql => "SELECT users.* FROM users, invitees, invitations  WHERE (`users`.email = `invitees`.email AND `invitees`.invitation_id = `invitations`.id)"
  has_one :default_organization, :class_name => "Organization"
  
  accepts_nested_attributes_for :invitees
  accepts_nested_attributes_for :default_organization

  def invitees_attributes=(attributes)
    attributes.each do |attr|
      invitees << invitees.build(attr.last) unless attr.last["email"].blank? || invitees.map(&:email).include?(attr.last["email"])
    end
  end
end
