class OrganizationRequest < ActiveRecord::Base
  belongs_to :jurisdiction
  belongs_to :organization
  belongs_to :approver, :class_name => "User", :foreign_key => "approver_id"
  has_one :organization_membership, :dependent => :destroy

  named_scope :unapproved, :conditions => ["approved = false"]
  named_scope :in_jurisdictions, lambda { |jurisdictions|
    {:conditions => ["jurisdiction_id in (?)", jurisdictions]}
  }

  validates_presence_of :jurisdiction
  validates_presence_of :organization

  attr_protected :approver_id

  def approved?
    true if approver
  end

  def approve!(approving_user)
    if approving_user.is_admin? && approving_user.jurisdictions.include?(jurisdiction) && !OrganizationMembership.already_exists?(organization, jurisdiction)
      self.approved = true
      self.approver=approving_user
      create_organization_membership(:organization => organization, :jurisdiction => jurisdiction)
      self.save
    end
  end

  def deny!
    self.destroy
  end
end