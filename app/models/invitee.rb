class Invitee < ActiveRecord::Base
  
  belongs_to :invitation
  has_one :user, :class_name => "User", :foreign_key => :email, :primary_key => :email
end
