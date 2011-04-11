#== Schema information
#
#    t.string   "tab_config"
#    t.integer  "user_id"
#    t.datetime "created_at"
#    t.datetime "updated_at"
#

class Favorite < ActiveRecord::Base
  belongs_to :user
  serialize :tab_config
  has_paper_trail :meta => { :item_desc  => Proc.new { |x| x.to_s } }

  def to_s
    tab_config['title']
  end
end
