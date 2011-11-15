class AudiencesRecipient < ActiveRecord::Base
  belongs_to :user
  belongs_to :audience
end
