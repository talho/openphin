
class Permission < ActiveRecord::Base
  belongs_to :share
  belongs_to :user
end