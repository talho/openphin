# == Schema Information
#
# Table name: articles
#
#  id         :integer(4)      not null, primary key
#  author_id  :integer(4)
#  pub_date   :integer(4)
#  title      :string(255)
#  lede       :text
#  body       :text
#  visible    :boolean(1)
#  created_at :datetime
#  updated_at :datetime
#

class Article < ActiveRecord::Base
	belongs_to :author, :class_name => "User"
	scope :recent, :limit => 3, :order => "pub_date desc"
  has_paper_trail :meta => { :item_desc  => Proc.new { |x| x.to_s } }

  def to_s
    title
  end

end
