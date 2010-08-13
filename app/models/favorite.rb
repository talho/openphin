class Favorite < ActiveRecord::Base
  belongs_to :user
  serialize :tab_config
end
