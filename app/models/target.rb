class Target < ActiveRecord::Base
  belongs_to :item, :polymorphic => true
  belongs_to :audience
end
