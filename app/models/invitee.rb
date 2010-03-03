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
end
