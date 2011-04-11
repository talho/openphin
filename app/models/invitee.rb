# == Schema Information
#
# Table name: invitees
#
#  id            :integer(4)      not null, primary key
#  name          :string(255)     not null
#  email         :string(255)     not null
#  ignore        :boolean(1)      default(FALSE), not null
#  invitation_id :integer(4)      not null
#  created_at    :datetime
#  updated_at    :datetime
#

class Invitee < ActiveRecord::Base
  belongs_to :invitation
  has_one :user, :class_name => "User", :foreign_key => :email, :primary_key => :email
  has_paper_trail :meta => { :item_desc  => Proc.new { |x| x.to_s } }
  cattr_reader :per_page
  @@per_page = 20

  after_create :create_org_membership

  def completion_status
    if user.nil?
      "Not Registered"
    elsif user.email_confirmed
      "Registered"
    else
      "Not Email Confirmed"
    end
  end

  def is_member?
    invitation.default_organization.members.include?(user) ? "Yes" : "No"
  end

  def to_s
    name
  end

  private
  def create_org_membership
    invitation.default_organization << user unless invitation.default_organization.nil? || user.nil?
  end

end
