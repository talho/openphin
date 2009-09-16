# == Schema Information
#
# Table name: organization_memberships
#
#  id                      :integer(4)      not null, primary key
#  organization_id         :integer(4)
#  jurisdiction_id         :integer(4)
#  organization_request_id :integer(4)
#  created_at              :datetime
#  updated_at              :datetime
#

class OrganizationMembership < ActiveRecord::Base
  belongs_to :organization
  belongs_to :jurisdiction
  belongs_to :organization_request, :dependent => :destroy
  has_one :approver, :through => :organization_request

  validates_presence_of :organization_id
  validates_presence_of :jurisdiction_id
  validates_presence_of :organization_request
  validates_uniqueness_of :organization_id, :scope => [ :jurisdiction_id ]

  def self.already_exists?(organization, jurisdiction)
    return true if OrganizationMembership.find_by_organization_id_and_jurisdiction_id(organization.id, jurisdiction.id)
    false
  end
end
